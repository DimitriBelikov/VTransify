from ibm_watson import SpeechToTextV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
import google_trans_new as gtn
import gtts
import os
from random import randint

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
        try:
            with open(audio_path, 'rb') as audio_file:
                audio_text_data = ibm_stt.recognize(audio=audio_file, content_type='application/octet-stream', model='en-US_NarrowbandModel', speech_detector_sensitivity=0.3, continous=True).get_result()
            print(audio_text_data)
            audio_text = audio_text_data['results'][0]['alternatives'][0]['transcript']
            print('Recognized Text : ', audio_text)
        except:
            audio_text = None
        return audio_text
    
    def __translateText(self, input_text, from_language, to_language):
        translator = gtn.google_translator()
        translated_text = translator.translate(input_text, lang_src=from_language, lang_tgt=to_language)
        print('Translated Text : ', translated_text)
        return translated_text
    
    def __translatedTexttoOutputAudio(self, translated_text, tgt_language):
        output_audio = gtts.gTTS(translated_text, lang=tgt_language)
        return output_audio
    
    def inputToOutputAudio(self, audio_path, to_lang='en-us', tgt_lang='hi'):
        recog_audio_text = self.__inputAudioToText(audio_path)
        
        if recog_audio_text != None:
            translated_text = self.__translateText(recog_audio_text, to_lang, tgt_lang)
            output_audio = self.__translatedTexttoOutputAudio(translated_text, tgt_lang)

            output_filename = audio_path[audio_path.rindex('\\')+1:]
            
            output_audio_path, response = os.path.join(os.getcwd(), 'output_data', output_filename), 200
            output_audio.save(output_audio_path)
            print('<========================================>\n')

            return {'response': response, 'output_filepath': output_audio_path, 'translated_text': translated_text}
        else:
            return None

class RandomTextGenerator:

    def generate_random_text(self):
        filename_length = randint(10,15)
        filename = ''
        for x in range(1, filename_length+1):
            random_2, random_3 = randint(1,10), 99
            
            if random_2 < 6:
                random_3 = str(randint(1,9))
            else:
                random_3 = chr(randint(65,90))

            filename += random_3
        return filename