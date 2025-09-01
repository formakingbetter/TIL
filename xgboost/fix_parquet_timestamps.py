#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
두 parquet의 시간열에서 +09:00 같은 타임존 표기를 제거(naive KST)하거나,
원할 경우 -9시간 시프트(UTC 정렬)해서 새 parquet 저장.

입력:
  scada:  dt, wind_speed_mps, wind_direction_degree, turbine_id
  label:  end_datetime, 구분, 시간, energy_mwh/energy_kwh

출력(기본: tz 제거, 로컬 KST naive):
  scada_yangyang_norm.parquet
  train_y_yangyang_norm.parquet
"""
import argparse
import pandas as pd
import numpy as np

def to_dt(s):
    # 문자열/오브젝트 → datetime. tz 포함돼 있으면 tz-aware로 파싱됨.
    return pd.to_datetime(s, errors="coerce")

def drop_tz_to_kst(series):
    """tz-aware면 Asia/Seoul로 변환→tz 정보 제거(naive KST), tz-naive면 그대로"""
    s = to_dt(series)
    # tz-aware?
    if getattr(s.dt, "tz", None) is not None:
        s = s.dt.tz_convert("Asia/Seoul").dt.tz_localize(None)
    return s

def shift_minus_9h(series):
    """모든 시각을 -9시간 이동(UTC 정렬하고 싶을 때)"""
    s = to_dt(series)
    # tz-aware면 먼저 KST 기준 naive로 맞춘 뒤 -9h
    if getattr(s.dt, "tz", None) is not None:
        s = s.dt.tz_convert("Asia/Seoul").dt.tz_localize(None)
    return s - pd.Timedelta(hours=9)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scada", default="scada_yangyang.parquet")
    ap.add_argument("--label", default="train_y_yangyang.parquet")
    ap.add_argument("--out-scada", default="scada_yangyang_norm.parquet")
    ap.add_argument("--out-label", default="train_y_yangyang_norm.parquet")
    ap.add_argument("--mode", choices=["drop-tz", "shift-9h"], default="drop-tz",
                    help="drop-tz: +09:00 같은 tz표시만 제거(시각 유지), shift-9h: 전체 -9시간 시프트")
    ap.add_argument("--engine", choices=["pyarrow","fastparquet"], default="fastparquet",
                    help="쓰기 엔진(설치된 것 사용). pyarrow가 말썽이면 fastparquet 권장")
    args = ap.parse_args()

    # 읽기: 설치된 엔진 자동
    try:
        import pyarrow  # noqa
        read_engine = "pyarrow"
    except Exception:
        try:
            import fastparquet  # noqa
            read_engine = "fastparquet"
        except Exception:
            raise SystemExit("[에러] parquet 엔진이 없습니다.  pip install fastparquet  (권장)")

    scada = pd.read_parquet(args.scada, engine=read_engine)
    label = pd.read_parquet(args.label, engine=read_engine)

    # 컬럼 리네임(병합 대비 통일; 지금은 파일 재저장이 목적이라 최소만)
    # 시간열 정규화
    if args.mode == "drop-tz":
        scada["dt"] = drop_tz_to_kst(scada["dt"])
        label["end_datetime"] = drop_tz_to_kst(label["end_datetime"])
    else:  # shift-9h
        scada["dt"] = shift_minus_9h(scada["dt"])
        label["end_datetime"] = shift_minus_9h(label["end_datetime"])

    # (선택) 저장 전 sanity print
    print("[scada] dt head:", scada["dt"].head().to_list())
    print("[label] end_datetime head:", label["end_datetime"].head().to_list())

    # 새 parquet로 저장
    scada.to_parquet(args.out_scada, engine=args.engine, index=False)
    label.to_parquet(args.out_label, engine=args.engine, index=False)
    print(f"[완료] 저장 → {args.out_scada}, {args.out_label} (mode={args.mode}, engine={args.engine})")

if __name__ == "__main__":
    main()
