from flask import Flask, request, send_from_directory
import os
from werkzeug.utils import secure_filename
from services import InputToOutputAudio, RandomTextGenerator
from json import dumps

server_app = Flask(__name__)
services = InputToOutputAudio()

server_app.config["OUTPUT_AUDIO"] = os.getcwd() + '\output_data'

@server_app.route('/translate-voice', methods=['POST'])
def translate_voice():
    try:
        audio_file = request.files['audio_file']
        audio_filename = RandomTextGenerator().generate_random_text() + audio_file.filename[audio_file.filename.rindex('.'):]
        audio_filepath = os.path.join(os.getcwd(), 'audio_data', audio_filename)

        print('\nAudio : '+ audio_filename)
        audio_file.save(audio_filepath)

        itoa = InputToOutputAudio()
        service_response = itoa.inputToOutputAudio(audio_path = audio_filepath)

        if service_response != None:
            response, output_audio = service_response
            html_responsedata = {'Response': response, 'redirect_path': audio_filename[:audio_filename.rindex('.')]}
        else:
            response = 500
            html_responsedata = {'Response': response}
    except:
        response = 400
        html_responsedata = {'Response': 'UploadError'}

    html_response = dumps(html_responsedata)
    return html_response

@server_app.route('/output-audio/<audiofile>', methods=['GET'])
def getaudio(audiofile):
    for files in os.listdir(os.path.join(os.getcwd(),'output_data')):
        if files[:files.index('.')] == audiofile:
            audio_filename = files
            audio_directory = os.path.join(server_app.root_path, server_app.config['OUTPUT_AUDIO'])
            print(audio_directory)

            return send_from_directory(directory=audio_directory, path=audio_filename, as_attachment=True)
    return '<h1> Error 500 - File Not Found </h1>'