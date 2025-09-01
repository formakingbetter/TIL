#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
양양 풍력 발전량 예측 스크립트 (SCADA 데이터 포함)
- train_y_yangyang_norm.parquet 와 scada_yangyang_norm.parquet 를 함께 사용
- SCADA 데이터를 예측 피처로 활용하여 예측 정확도 향상
- 예측 날짜: 2024-09-16 (홀수 달)
- 결과: result.csv (long), result_wide.csv (wide)
"""
from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np
import pandas as pd
from zoneinfo import ZoneInfo
from xgboost import XGBRegressor

# ====================== 사용자 설정 ======================
FILE_Y = "train_y_yangyang_norm.parquet"
FILE_SCADA = "scada_yangyang_norm.parquet"
PREDICT_DATE = "2024-09-16"
MONTH_FILTER = "odd"
MIN_ROWS_PLANT = 50
RANDOM_STATE = 42
SAVE_LONG = "result_with_scada.csv"
SAVE_WIDE = "result_wide_with_scada.csv"
PRINT_HEAD = 10
# =========================================================

KST = ZoneInfo("Asia/Seoul")

def _engine() -> str:
    try:
        import fastparquet  # noqa
        return "fastparquet"
    except Exception:
        pass
    try:
        import pyarrow  # noqa
        return "pyarrow"
    except Exception:
        pass
    raise SystemExit("[에러] parquet 엔진 없음.  pip install fastparquet  또는  pip install pyarrow")

ENGINE = _engine()

# ----------------------- 유틸 -----------------------
def to_kst_aware(s: pd.Series) -> pd.Series:
    dt = pd.to_datetime(s, errors="coerce")
    if getattr(dt.dt, "tz", None) is None:
        return dt.dt.tz_localize(KST)
    return dt.dt.tz_convert(KST)

def plant_norm(x) -> str:
    t = re.sub(r"[^0-9A-Za-z]+", "", str(x)).upper()
    if re.fullmatch(r"\d+", t or ""):
        return t.lstrip("0") or "A"
    return t or "A"

def looks_like_date_token(v: str) -> bool:
    return bool(re.fullmatch(r"\d{6,8}", v or ""))

def is_valid_plant_column(series: pd.Series, nrows: int) -> bool:
    vals = series.astype(str).map(lambda x: re.sub(r"\s+", "", x))
    nunique = vals.nunique(dropna=True)
    if nunique <= 1:
        return False
    if nunique > max(30, nrows // 3):
        return False
    sample = vals.sample(min(200, len(vals)), random_state=0) if len(vals) > 200 else vals
    if (sample.map(looks_like_date_token).mean() > 0.7):
        return False
    alpha_ratio = sample.map(lambda s: bool(re.search(r"[A-Za-z]", s))).mean()
    if alpha_ratio < 0.3:
        return False
    return True

def guess_col(df: pd.DataFrame, cands: List[str]) -> Optional[str]:
    for c in cands:
        if c in df.columns:
            return c
    lower = {c.lower(): c for c in df.columns}
    for c in cands:
        if c.lower() in lower:
            return lower[c.lower()]
    return None

def unify_columns(df: pd.DataFrame, is_scada: bool) -> Tuple[pd.DataFrame, str, str]:
    d = df.copy()
    nrows = len(d)

    # 시간
    tcol = guess_col(d, ["timestamp","end_datetime","dt","time","시간","datetime","date_time"])
    if not tcol:
        raise SystemExit(f"[에러] 시간 컬럼을 찾지 못했습니다: {tcol}")
    d = d.rename(columns={tcol: "timestamp"})
    d["timestamp"] = to_kst_aware(d["timestamp"]).dt.floor("h")

    # 플랜트 (id 제외)
    pcol_guess = guess_col(d, ["plant","구분","turbine_id","unit","unit_id","wtg","wtg_id"])
    pcol: Optional[str] = None
    if pcol_guess and is_valid_plant_column(d[pcol_guess], nrows):
        pcol = pcol_guess

    if pcol:
        d = d.rename(columns={pcol: "plant"})
        d["plant"] = d["plant"].map(plant_norm).astype(str)
        chosen_plant_info = f"{pcol} → plant (유효)"
    else:
        d["plant"] = "GLOBAL"
        chosen_plant_info = "플랜트 컬럼 없음/무효 → GLOBAL 단일 플랜트"

    if not is_scada:
        # 타깃
        ycol = guess_col(d, ["energy_kwh","energy","y","target","kwh","generation","output","발전량"])
        if not ycol:
            raise SystemExit(f"[에러] 타깃(발전량) 컬럼을 찾지 못했습니다: {ycol}")
        d = d.rename(columns={ycol: "y"})
        d = d.dropna(subset=["timestamp","y"])

    # 중복 (timestamp, plant) → 평균
    agg_cols = ["y"] if not is_scada else ["wind_speed_mps", "wind_direction_degree"]
    d = d.groupby(["timestamp","plant"], as_index=False, observed=True).agg({c: "mean" for c in agg_cols})

    print(f"[INFO] {FILE_Y if not is_scada else FILE_SCADA} → 시간: {tcol} / 플랜트: {chosen_plant_info}")
    return d, "timestamp", "plant"

def month_parity_label(m: int) -> str:
    return "odd" if m % 2 == 1 else "even"

def month_filter_df(df: pd.DataFrame, mode: str, target_date: pd.Timestamp) -> pd.DataFrame:
    if mode not in {"odd","even","auto"}:
        mode = "auto"
    if mode == "auto":
        mode = month_parity_label(int(target_date.month))

    if mode == "odd":
        use = df[df["timestamp"].dt.month % 2 == 1]
    else:
        use = df[df["timestamp"].dt.month % 2 == 0]

    if len(use) < 100:
        print(f"[WARN] {mode} month 데이터가 100행 미만 → 전체 데이터로 완화")
        return df.copy()
    return use.copy()

def add_calendar_cols(f: pd.DataFrame) -> pd.DataFrame:
    f = f.copy()
    f["year"] = f["timestamp"].dt.year.astype(int)
    f["month"] = f["timestamp"].dt.month.astype(int)
    f["day"] = f["timestamp"].dt.day.astype(int)
    f["dow"] = f["timestamp"].dt.dayofweek.astype(int)
    f["hour"] = f["timestamp"].dt.hour.astype(int)
    f["is_weekend"] = (f["dow"] >= 5).astype(int)
    f["sin_hour"] = np.sin(2*np.pi*(f["hour"]/24.0))
    f["cos_hour"] = np.cos(2*np.pi*(f["hour"]/24.0))
    f["sin_dow"]  = np.sin(2*np.pi*(f["dow"]/7.0))
    f["cos_dow"]  = np.cos(2*np.pi*(f["dow"]/7.0))
    f["sin_mon"]  = np.sin(2*np.pi*(f["month"]/12.0))
    f["cos_mon"]  = np.cos(2*np.pi*(f["month"]/12.0))
    return f

def build_stats(train: pd.DataFrame) -> Dict[str, pd.DataFrame]:
    t = add_calendar_cols(train[["timestamp","plant","y"]])
    stats: Dict[str, pd.DataFrame] = {}
    stats["ph"]  = t.groupby(["plant","hour"], observed=True)["y"].mean().rename("m_ph").reset_index()
    stats["pdh"] = t.groupby(["plant","dow","hour"], observed=True)["y"].mean().rename("m_pdh").reset_index()
    stats["pmh"] = t.groupby(["plant","month","hour"], observed=True)["y"].mean().rename("m_pmh").reset_index()
    stats["gh"]  = t.groupby(["hour"], observed=True)["y"].mean().rename("m_gh").reset_index()
    stats["gdh"] = t.groupby(["dow","hour"], observed=True)["y"].mean().rename("m_gdh").reset_index()
    stats["gmh"] = t.groupby(["month","hour"], observed=True)["y"].mean().rename("m_gmh").reset_index()
    return stats

def apply_stats(f: pd.DataFrame, stats: Dict[str, pd.DataFrame]) -> pd.DataFrame:
    f = add_calendar_cols(f[["timestamp","plant"]])
    f = f.merge(stats["ph"],  on=["plant","hour"], how="left")
    f = f.merge(stats["pdh"], on=["plant","dow","hour"], how="left")
    f = f.merge(stats["pmh"], on=["plant","month","hour"], how="left")
    f = f.merge(stats["gh"],  on=["hour"], how="left")
    f = f.merge(stats["gdh"], on=["dow","hour"], how="left")
    f = f.merge(stats["gmh"], on=["month","hour"], how="left")
    for c in ["m_ph","m_pdh","m_pmh","m_gh","m_gdh","m_gmh"]:
        if c in f.columns:
            f[c] = f[c].fillna(f["m_gh"]).fillna(0.0)
    return f

def make_global_X(df_features: pd.DataFrame) -> Tuple[pd.DataFrame, List[str]]:
    onehot = pd.get_dummies(df_features["plant"], prefix="plant", dtype=np.uint8)
    X = pd.concat([df_features.drop(columns=["plant"]), onehot], axis=1)
    feature_cols = [
        "year","month","day","dow","hour","is_weekend",
        "sin_hour","cos_hour","sin_dow","cos_dow","sin_mon","cos_mon",
        "m_ph","m_pdh","m_pmh","m_gh","m_gdh","m_gmh",
        "wind_speed_mps", "wind_direction_degree"
    ] + list(onehot.columns)
    X = X[feature_cols]
    return X, feature_cols

def make_local_X(df_features: pd.DataFrame) -> Tuple[pd.DataFrame, List[str]]:
    feature_cols = [
        "year","month","day","dow","hour","is_weekend",
        "sin_hour","cos_hour","sin_dow","cos_dow","sin_mon","cos_mon",
        "m_ph","m_pdh","m_pmh","m_gh","m_gdh","m_gmh",
        "wind_speed_mps", "wind_direction_degree"
    ]
    X = df_features[feature_cols]
    return X, feature_cols

def train_and_predict(
    df_y: pd.DataFrame,
    df_scada: pd.DataFrame,
    predict_date: str = PREDICT_DATE,
    month_filter: str = MONTH_FILTER,
    min_rows_plant: int = MIN_ROWS_PLANT,
    random_state: int = RANDOM_STATE,
) -> pd.DataFrame:
    # 데이터셋 통합
    merged_df = pd.merge(df_y, df_scada, on=["timestamp", "plant"], how="inner")
    print(f"[INFO] Y 데이터와 SCADA 데이터 병합 완료. 총 {len(merged_df)}행")

    # 표준화
    merged_df = merged_df.dropna(subset=["y", "wind_speed_mps", "wind_direction_degree"])

    pred_date = pd.Timestamp(predict_date).tz_localize(KST)
    train_df = month_filter_df(merged_df, month_filter, pred_date)

    stats = build_stats(train_df)

    feat_train = apply_stats(train_df[["timestamp","plant"]], stats)
    feat_train = pd.merge(feat_train, train_df[["timestamp", "plant", "wind_speed_mps", "wind_direction_degree"]], on=["timestamp", "plant"], how="left")
    Xg, _ = make_global_X(feat_train)
    y = train_df["y"].values

    ts24 = pd.date_range(
        pd.Timestamp(predict_date).tz_localize(KST).replace(hour=0, minute=0, second=0, microsecond=0),
        periods=24, freq="h"
    )
    plants = sorted(train_df["plant"].unique().tolist())
    grid = pd.MultiIndex.from_product([ts24, plants], names=["timestamp","plant"]).to_frame(index=False)
    feat_test = apply_stats(grid, stats)
    # 예측할 SCADA 데이터는 없으므로 0으로 채움
    feat_test["wind_speed_mps"] = 0.0
    feat_test["wind_direction_degree"] = 0.0

    Xg_test, _ = make_global_X(feat_test)

    by_plant = train_df.groupby("plant").size()
    use_local = set(by_plant[by_plant >= min_rows_plant].index.tolist())

    global_model = XGBRegressor(
        n_estimators=800,
        max_depth=6,
        learning_rate=0.05,
        subsample=0.8,
        colsample_bytree=0.8,
        min_child_weight=1.0,
        reg_lambda=1.0,
        objective="reg:squarederror",
        tree_method="hist",
        random_state=random_state,
        n_jobs=0,
    )
    global_model.fit(Xg, y)

    pred_df = feat_test[["timestamp","plant"]].copy()
    pred_df["energy_kwh_pred"] = global_model.predict(Xg_test)

    for p in sorted(list(use_local)):
        tr_p = train_df[train_df["plant"] == p].copy()
        ft_p = apply_stats(tr_p[["timestamp","plant"]], stats)
        ft_p = pd.merge(ft_p, tr_p[["timestamp", "plant", "wind_speed_mps", "wind_direction_degree"]], on=["timestamp", "plant"], how="left")
        Xp, _ = make_local_X(ft_p)
        yp = tr_p["y"].values

        te_mask = (feat_test["plant"] == p)
        Xp_test, _ = make_local_X(feat_test.loc[te_mask])

        local_model = XGBRegressor(
            n_estimators=600,
            max_depth=6,
            learning_rate=0.05,
            subsample=0.9,
            colsample_bytree=0.9,
            min_child_weight=1.0,
            reg_lambda=1.0,
            objective="reg:squarederror",
            tree_method="hist",
            random_state=random_state,
            n_jobs=0,
        )
        local_model.fit(Xp, yp)
        pred_df.loc[te_mask, "energy_kwh_pred"] = local_model.predict(Xp_test)

    pred_df["energy_kwh_pred"] = pred_df["energy_kwh_pred"].clip(lower=0.0)
    pred_df = pred_df.sort_values(["plant","timestamp"]).reset_index(drop=True)
    pred_df["timestamp"] = pred_df["timestamp"].dt.tz_convert(KST)

    return pred_df[["timestamp","plant","energy_kwh_pred"]]

def main():
    fp_y = Path(FILE_Y)
    if not fp_y.exists():
        raise SystemExit(f"[에러] 파일을 찾지 못했습니다: {Path(FILE_Y).resolve()}")
    raw_y = pd.read_parquet(fp_y, engine=ENGINE)
    df_y, _, _ = unify_columns(raw_y, is_scada=False)

    fp_scada = Path(FILE_SCADA)
    if not fp_scada.exists():
        raise SystemExit(f"[에러] 파일을 찾지 못했습니다: {Path(FILE_SCADA).resolve()}")
    raw_scada = pd.read_parquet(fp_scada, engine=ENGINE)
    df_scada, _, _ = unify_columns(raw_scada, is_scada=True)

    result = train_and_predict(df_y, df_scada, predict_date=PREDICT_DATE, month_filter=MONTH_FILTER)

    out_long = Path(SAVE_LONG)
    result.to_csv(out_long, index=False, encoding="utf-8")
    print(f"[완료] 예측 결과 저장(long): {out_long.resolve()}")

    out_wide = result.pivot_table(index="timestamp", columns="plant", values="energy_kwh_pred", aggfunc="mean").reset_index()
    out_wide.to_csv(SAVE_WIDE, index=False, encoding="utf-8")
    print(f"[완료] 예측 결과 저장(wide): {Path(SAVE_WIDE).resolve()}")

    print("[미리보기 — long]")
    print(result.head(PRINT_HEAD).to_string(index=False))

if __name__ == "__main__":
    main()
