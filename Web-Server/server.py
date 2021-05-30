from flask import Flask, request, send_from_directory
import os
from werkzeug.utils import secure_filename
from services import InputToOutputAudio, RandomTextGenerator
from json import dumps

server_app = Flask(__name__)
services = InputToOutputAudio()

@server_app.route('/translate-voice', methods=['POST'])
def translate_voice():
    audio_file = request.files['audio_file']
    audio_filename = RandomTextGenerator().generate_random_text() + audio_file.filename[audio_file.filename.rindex('.'):]
    audio_filepath = os.path.join(os.getcwd(), 'audio_data', audio_filename)

    print('\nAudio : '+ audio_filename)
    audio_file.save(audio_filepath)

    itoa = InputToOutputAudio()
    response, output_audio = itoa.inputToOutputAudio(audio_path = audio_filepath)

    html_responsedata = {'Response': response, 'redirect_path': audio_filename[:audio_filename.rindex('.')]}
    html_response = dumps(html_responsedata)

    return html_response

@server_app.route('/output-audio/<audiofile>', methods=['GET'])
def getaudio(audiofile):
    audio_filename = audiofile + '.mp3'
    audio_directory = os.path.join(os.getcwd(), 'output_data')

    return send_from_directory(audio_directory, path=audio_filename)