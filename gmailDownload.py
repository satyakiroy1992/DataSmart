# Something in lines of http://stackoverflow.com/questions/348630/how-can-i-download-all-emails-with-pdfs-from-gmail
# Make sure you have IMAP enabled in your gmail settings.
# Right now it won't download same file name twice even if their contents are different.

import email
import getpass, imaplib
import os
import sys
import logging

#detach_dir = '/Users/satyakiroy/Documents/R/'
detach_dir = sys.argv[1]
print(detach_dir)
if 'pdfs' not in os.listdir(detach_dir):
    os.mkdir(detach_dir +'/pdfs')

#userName = raw_input('Enter your GMail username:')
userName = sys.argv[2]
print(userName)
#passwd = getpass.getpass('Enter your password: ')
passwd  = sys.argv[3]

emailFolder = sys.argv[4]
print (emailFolder)

try:
    imapSession = imaplib.IMAP4_SSL('imap.gmail.com')
    typ, accountDetails = imapSession.login(userName, passwd)
    if typ != 'OK':
        print ('Not able to sign in!')
        raise
    
    label = '[Gmail]/All Mail'
    if emailFolder:
        listOfFolders  = imapSession.list()
        for nameList in listOfFolders :
            for folder in nameList:
                if folder.find(emailFolder)!=-1 :
                    print (label)
                    label = emailFolder
                    break
        if(label == '[Gmail]/All Mail'):
            print(emailFolder + " not found. Setting to default folder to [Gmail]/All Mail")     
        
    print (label)
    imapSession.select(label)
    typ, data = imapSession.search(None, 'ALL')
    if typ != 'OK':
        print ('Error searching Inbox.')
        raise
    
    # Iterating over all emails
    for msgId in data[0].split():
        typ, messageParts = imapSession.fetch(msgId, '(RFC822)')
        if typ != 'OK':
            print ('Error fetching mail.')
            raise

        emailBody = messageParts[0][1]
        mail = email.message_from_string(emailBody)
        for part in mail.walk():
            if part.get_content_maintype() == 'multipart':
                # print part.as_string()
                continue
            if part.get('Content-Disposition') is None:
                # print part.as_string()
                continue
            fileName = part.get_filename()

            if bool(fileName):
                filePath = os.path.join(detach_dir, 'pdfs', fileName)
                if not os.path.isfile(filePath) :
                    print (fileName)
                    fp = open(filePath, 'wb')
                    fp.write(part.get_payload(decode=True))
                    fp.close()
    imapSession.close()
    imapSession.logout()
except Exception as e :
    print ('Not able to download all pdfs.')
    logging.exception("message")
