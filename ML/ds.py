# Generate an Excel file with 162 randomized responses for the user's 6-question form
import pandas as pd
import numpy as np
from collections import Counter

np.random.seed(42)  # reproducible

# Q1: Age groups with a plausible distribution
q1_opts = ['10대','20대','30대','40대','50대','60대 이상']
q1_weights = np.array([0.05, 0.30, 0.30, 0.20, 0.10, 0.05])

# Q2: Importance (5-point)
q2_opts = ['매우 중요','중요','보통','중요하지 않음','전혀 중요하지 않음']
q2_weights = np.array([0.35, 0.35, 0.20, 0.07, 0.03])

# Q3: Selection criterion (single choice)
q3_opts = ['가격','음식의종류','현지인 추천','인터넷 검색 후기','지인 추천','숙소 근처','유명 프랜차이즈','기타']
q3_weights = np.array([0.18,0.17,0.20,0.20,0.10,0.08,0.05,0.02])

# Q4: Disappointed at famous restaurants in Gangneung? 70% '예'
q4_opts = ['예','아니오']
q4_weights = np.array([0.70,0.30])

# Q5: Would use platform? (4-point)
q5_opts = ['매우 그렇다','보통이다','그렇지 않다','전혀 그렇지 않다']
q5_weights = np.array([0.45,0.35,0.15,0.05])

# Q6: Desired info (multi-select). We'll generate 2~4 choices per respondent
q6_opts = ['현지인이 추천하는 메뉴','음식점 분위기(조용함, 시끌벅적함 등)','가격대','영업시간','예약 가능 여부','결제 방법(현금만 가능한지 등)','주차 가능 여부','기타']
q6_base_weights = np.array([0.25,0.14,0.20,0.14,0.10,0.09,0.07,0.01])

def weighted_choice(opts, weights):
    w = weights / weights.sum()
    return np.random.choice(opts, p=w)

def multi_select(opts, weights, kmin=2, kmax=4):
    k = np.random.randint(kmin, kmax+1)
    # sample without replacement by weights
    w = weights / weights.sum()
    idx = np.random.choice(np.arange(len(opts)), size=k, replace=False, p=w)
    picked = [opts[i] for i in idx]
    return picked

rows = []
N = 162
for i in range(N):
    q1 = weighted_choice(q1_opts, q1_weights)
    q2 = weighted_choice(q2_opts, q2_weights)
    q3 = weighted_choice(q3_opts, q3_weights)
    q4 = weighted_choice(q4_opts, q4_weights)
    q5 = weighted_choice(q5_opts, q5_weights)
    q6 = multi_select(q6_opts, q6_base_weights, 2, 4)
    rows.append({
        'Q1': q1,
        'Q2': q2,
        'Q3': q3,
        'Q4': q4,
        'Q5': q5,
        # Use pipe delimiter for checkbox multi-select, matching the Apps Script importer
        'Q6': '|'.join(q6),
    })

responses_df = pd.DataFrame(rows, columns=['Q1','Q2','Q3','Q4','Q5','Q6'])

# Build Map sheet for ItemID mapping
map_df = pd.DataFrame({
    'LogicalKey': ['Q1','Q2','Q3','Q4','Q5','Q6'],
    'ItemID': ['', '', '', '', '', '']  # user fills
})

# README
readme_lines = [
    ["이 파일은 6문항(단일선택 5, 체크박스 1)의 무작위 162명 응답입니다."],
    ["- Q4(유명 맛집 실망 경험)는 '예'가 약 70%가 되도록 샘플링했습니다."],
    ["- Q6(복수선택)는 2~4개 항목을 무작위로 선택했으며, 텍스트는 | 로 구분되어 있습니다."],
    ["사용 방법:"],
    ["1) 이 파일을 Google 드라이브에 업로드 → Google 스프레드시트로 열기"],
    ["2) 'Map' 시트에서 각 문항의 ItemID를 채우십시오(앱스 스크립트 logFormItems()로 확인)."],
    ["3) 제공된 Apps Script로 'Responses' 시트를 읽어 폼으로 제출하십시오."],
]
readme_df = pd.DataFrame(readme_lines, columns=["Guide"])

# Summary sheet for quick verification
def freq_series(values, name):
    cnt = Counter(values)
    return pd.DataFrame({'항목': list(cnt.keys()), '빈도': list(cnt.values())}).sort_values('빈도', ascending=False).assign(문항=name)

summary_frames = [
    freq_series(responses_df['Q1'], 'Q1'),
    freq_series(responses_df['Q2'], 'Q2'),
    freq_series(responses_df['Q3'], 'Q3'),
    freq_series(responses_df['Q4'], 'Q4'),
    freq_series(responses_df['Q5'], 'Q5'),
]
summary_df = pd.concat(summary_frames, ignore_index=True)

# Calculate Q4 yes ratio
q4_yes_ratio = (responses_df['Q4'] == '예').mean()

# Add a metrics sheet
metrics_df = pd.DataFrame({
    '지표': ['총 표본수', 'Q4 예 비율'],
    '값': [N, round(float(q4_yes_ratio), 4)]
})

# Save
path = "GoogleForm_162_Randomized.xlsx"
with pd.ExcelWriter(path, engine="xlsxwriter") as writer:
    readme_df.to_excel(writer, index=False, sheet_name="README")
    map_df.to_excel(writer, index=False, sheet_name="Map")
    responses_df.to_excel(writer, index=False, sheet_name="Responses")
    summary_df.to_excel(writer, index=False, sheet_name="Summary")
    metrics_df.to_excel(writer, index=False, sheet_name="Metrics")

path
