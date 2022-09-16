from flask import Flask, request, render_template, redirect, url_for
from waitress import serve
import base64

password = "123" #change the password

app = Flask(__name__)
data_to_show = "default"

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/update')
def update():
    return data_to_show

@app.route('/imgdata')
def imgdata():
    global data_to_show
    if request.args.get('pass') == password:
        if request.args.get('data'):
            base64_message = request.args.get('data') 
            base64_bytes = base64_message.encode('ascii')
            message_bytes = base64.b64decode(base64_bytes)
            data_to_show = message_bytes.decode('ascii')
            return str(data_to_show)
        elif request.args.get('reset'):
            data_to_show = "default/"
            return str(data_to_show)
        else:
            return "Error occurred"
    else:
        return "Incorrect password"

if __name__ == "__main__":
    serve(app, host="0.0.0.0", port=80)
    #app.run(host="0.0.0.0", port=80) #<- use this to get the development server