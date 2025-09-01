import os, sys, glob
print("Python:", sys.version.split()[0])
print("cwd   :", os.getcwd())
print("here  :", glob.glob("*.py"))
print("OK - ds.py 실행 완료")
