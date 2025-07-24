'''
[pip install fastapi] 로 fastapi 라이브러리 설치 후 진행
'''

from fastapi import FastAPI
import random

app = FastAPI()

@app .get('/hi')
def hi():
    return {'status' : 'ok'}

@app.get('/lotto')
def lotto():
    return{
        'number': random.sample(range(1,46),6)
    }
