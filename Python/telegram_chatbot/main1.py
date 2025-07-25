import requests
from fastapi import FastAPI

api1 = FastAPI()

@api1.get('/hi1')

def hi():
    return {'status':'hi'}

@api1.get('/clone')

def clone():
    return {'status':'hohoho'}
@api1.get('/clonec')

def clonec():
    return {'status':'hoho'}

def send_message(chat_id, message):
    bot_token = '8404158589:AAHig7FG__VO5bq_5AJYgxW5dMAeuBxiOFM'
    URL = f'https://api.telegram.org/bot{bot_token}'
    body = {
        'chat_id': chat_id,
        'text' : message
    }
    requests.get(URL + '/getUpgrades',body).json()