#!/usr/bin/env python

import opc, time
import os
import tweepy
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import time
import string
import sys
import keys
import json
import threading


class myThread (threading.Thread):
    def __init__(self, threadID, name, counter):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.counter = counter
    
    def run(self):
        print("Starting " + self.name)
        push_pixels(self.name, self.counter)
        print("Exiting " + self.name)


class MyListener(StreamListener):
    def on_data(self, data):
        for word in words:
            if word in data:
                i =  words.index(word)
                counts[i] = (5 + counts[i])%255                  
        return True

    def on_error(self, status):
        print(status)
        return True
    
numLEDs = 512
client = opc.Client('10.3.141.1:7890')


def push_pixels(threadName, delay):
    print(counts)
    for i in range(len(counts)):
        pixels[i] = (0, counts[i], counts[i]) 
        client.put_pixels(pixels)
    time.sleep(0.2)


if __name__ == '__main__':
    # wort = input("Bitte wählen Sie eine Zeichenkette, zu der Sie Daten sammeln möchten: ")
    # jumpback()
    
    counts = []

    with open('wordlist.txt') as wlst:
        words = wlst.read().split() 

    for i in range(len(words)):
        counts.append(0)
 
    for i in range(numLEDs):
        pixels = [ (0,0,0) ] * numLEDs

    # print("Daten werden gesammelt...") 
    auth = OAuthHandler(keys.consumer_key, keys.consumer_secret)
    auth.set_access_token(keys.access_token, keys.access_secret)
    api = tweepy.API(auth)

    # Create new threads
    thread1 = myThread(1, "Thread-1", 1)

    # Start new Threads
    thread1.start()

    twitter_stream = Stream(auth, MyListener())
    twitter_stream.filter(track=words)

