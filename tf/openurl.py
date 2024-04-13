import asyncio
from urllib.request import urlopen
from urllib.error import URLError
from contextlib import closing
URL = "https://www.google.com"


async def job():
    """execute openurl in async mode"""
    loop = asyncio.get_event_loop()
    try:
        oss_datas = await loop.run_in_executor(None, urlopen, URL)
    except Exception:
        message = f'request failure : {URL}'
        print(message)
    else:
        print("async mode is successfull")

try:
    with closing(urlopen(URL)) as prev:
        results = prev.read()
except URLError as error:
    message = f'erreur {error}'
    print(message, flush=True)
else:
    print("sync mode is successfull")

asyncio.run(job())
