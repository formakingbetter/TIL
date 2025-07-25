'''
[pip install fastapi] 로 fastapi 라이브러리 설치 후 진행
'''

from fastapi import FastAPI, Request
import random
import requests 

app = FastAPI()
 
@app .get('/hi')
def hi():
    return {'status' : 'ok'}
# uvicorn main:app --reload
# http://localhost:8000/
# http://127.0.0.1:8000

@app.get('/lotto')
def lotto():
    return{
        'number': random.sample(range(1,46),6)
    }
@app.get('/')
def home():
    return {'home':'sweet home'}
@app.get('/hihi')
def hihi():
    return {'hihi':'hihihi'}

@app.get('/score')
def score():
    return {'score':'hellohello'}
@app.get('/crazy')
def crazy():
    return {'crazy':'hell'}
# /telegram 라우팅으로 텔레그램 서버가 Bot에 업데이트가 있을 경우, 우리에게 알려줌


# def send_message(chat_id, message):
#     bot_token = '8404158589:AAHig7FG__VO5bq_5AJYgxW5dMAeuBxiOFM'
#     URL = f'https://api.telegram.org/bot{bot_token}'
#     body = {
#         # 사용자 chat_id는 어디서 가져옴 ..?
#         'chat_id': chat_id,
#         'text': message
#     }
#     requests.get(URL +'/sendMessage',body)

def sender_id(sender_id ,message):
     bot_token = '8404158589:AAHig7FG__VO5bq_5AJYgxW5dMAeuBxiOFM'
     URL = f'https://api.telegram.org/bot{bot_token}'
     body = {
        'chat_id': sender_id,
        'text' : message
    }
    requests.get(URL + '/sendMessage',body)    

@app.post('/telegram')
async def telegram(request: Request):
    print('텔레그램에서 요청이 들어왔다!!!')

    data = await request.json()
    sender_id = data['message']['chat']['id']
    input_msg = data['message']['text']
    print(data)

    send_message(sender_id, input_msg)
    return {'status':'굿'}
@app.get('/clone')
def clone():
    return {'status' : 'clone'}
@app.get('/lotto1')
def lotto1():
    return {'status' : ','.join(map(str,random.sample(range(1,46),6)))}
