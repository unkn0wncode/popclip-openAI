import requests, os
from subprocess import Popen, PIPE, call

def queryOpenAI(prompt, input):
    base_url = "https://api.openai.com/v1"
    headers = {"Authorization": f"Bearer {os.environ['POPCLIP_OPTION_APIKEY']}"}
    messages = [
        {"role": "system", "content": prompt},
        {"role": "user", "content": input}
    ]
    data = {
        "model": "gpt-3.5-turbo",
        "messages": messages
    }
    response = requests.post(f"{base_url}/chat/completions", json=data, headers=headers)
    response.raise_for_status()
    content = response.json()['choices'][0]['message']['content'].strip()
    return content

def get_user_text():
    script = """display dialog "Enter the data you want to send:" default answer ""
set dataToSend to the text returned of the result
return dataToSend"""
    p = Popen(['osascript', '-'], stdin=PIPE, stdout=PIPE, stderr=PIPE, universal_newlines=True, text=True)
    stdout, stderr = p.communicate(script)
    if stderr != "":
        exit()
    return stdout.strip()

def show_response_dialog(content):
    script = f'''display dialog "Response: {content}" buttons {{"Copy", "OK"}} default button 2
    set button to the button returned of the result
    return button
    '''
    p = Popen(['osascript', '-'], stdin=PIPE, stdout=PIPE, stderr=PIPE, universal_newlines=True, text=True)
    stdout, stderr = p.communicate(script)
    if stdout.strip() == "Copy":
        call((
            'osascript',
            '-e',
            f'set the clipboard to "{content}"'
        ))

if __name__ == "__main__":
    user_text = get_user_text()
    response_text = queryOpenAI(user_text, os.environ['POPCLIP_TEXT'])
    show_response_dialog(response_text.replace('"','\\"').replace("'","\\'"))