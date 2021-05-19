from ibm_watson import SpeechToTextV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
import google_trans_new as gtn
import gtts
import os

sttapikey = 'wW82XoUPgI4tey3TfmY4LKiEeib_iqcJ5FwFt54PyTS_'
stturl = 'https://api.us-east.speech-to-text.watson.cloud.ibm.com/instances/e4d9d9ef-9aa9-4f68-a9bb-5ce2f38bf147'

class InputToOutputAudio:
    
    def authenticator(self):
        sttauthenticator = IAMAuthenticator(sttapikey)
        stt = SpeechToTextV1(authenticator=sttauthenticator)
        stt.set_service_url(stturl)
        return stt

    def __inputAudioToText(self, audio_path):
        ibm_stt = self.authenticator()
        with open(audio_path, 'rb') as audio_file:
            audio_text_data = ibm_stt.recognize(audio=audio_file, content_type='audio/mp3', model='en-AU_NarrowbandModel', continuous=True).get_result()
        audio_text = audio_text_data['results'][0]['alternatives'][0]['transcript']
        print('Recognized Text : ', audio_text)
        return audio_text
    
    def __translateText(self, input_text, from_language, to_language):
        translator = gtn.google_translator()
        translated_text = translator.translate(input_text, lang_src=from_language, lang_tgt=to_language)
        print('Translated Text : ', translated_text)
        return translated_text
    
    def __translatedTexttoOutputAudio(self, translated_text, tgt_language):
        output_audio = gtts.gTTS(translated_text, lang=tgt_language)
        return output_audio
    
    def inputToOutputAudio(self, audio_data, to_lang='en-us', tgt_lang='hi'):
        recog_audio_text = self.__inputAudioToText(audio_data)
        translated_text = self.__translateText(recog_audio_text, to_lang, tgt_lang)
        output_audio = self.__translatedTexttoOutputAudio(translated_text, tgt_lang)

        output_audio_path = os.path.join(os.getcwd(), 'output_data', 'sample.mp3')
        output_audio.save(output_audio_path)
        return output_audio_path