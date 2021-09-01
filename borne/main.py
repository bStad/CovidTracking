import subprocess
import time
import requests
import helpers

serverURL = "http://192.168.0.45:8080"
interfaceURL = serverURL + "/proxmarkinterface"

lockedMSN = ""
noCardCounter = 0   # Used to reset the locked msn after a while



def handleOnlyMSN(currentMSN): # Handle the case where we send only the MSN
    serverResponse = requests.post(interfaceURL, data={'msn': currentMSN, 'ci': Course_ID})
    # Server's response is either a HTTPPartialContent or HTTPOk
    if(serverResponse.status_code == 206):  #PartialContent, ask for student number
        handleStudentNumberAndMSN(currentMSN)
    elif(serverResponse.status_code == 200): #HTTPOk
        print("Attendance registered. Have a great course!")
    else: #Unexpected error
        print("Unexpected error while linking your profile to your card. Please try again or use the app.")

def handleStudentNumberAndMSN(currentMSN): # Handle the case where we send an MSN and a student number
    print("To link your card to your profile, the student number on the card is needed.") 
    print("This is only needed once.")
    studentNumber = helpers.inputStudentNumber()
    # Input looks valid, send it to server
    serverResponse = requests.post(interfaceURL, data={'msn': currentMSN, 'sn': studentNumber, 'ci': Course_ID})
    # Server's response is either a HTTPPartialContent again, or a HTTPOk
    if(serverResponse.status_code == 206):
        handleFullProfile(currentMSN, studentNumber)
    elif(serverResponse.status_code == 200): #HTTPOk
        print("Your profile was linked to your card successfully. Thank you for your patience. Have a good course!")
    else: # Unexpected, other problem
        print("There was an unexpected error while saving your data. Please try again later or use the app.")

def handleFullProfile(currentMSN, studentNumber): # Handle the case where we send a full profile with the MSN
    #Student number isn't in the db, we need full profile info.
    print("It appears you do not have a profile on the server. Let's create it now.")
    firstName = helpers.inputName("first")
    lastName = helpers.inputName("last")
    email = helpers.inputEmail()
    serverResponse = requests.post(interfaceURL, data=
        {'msn': currentMSN, 'sn': studentNumber, 'ci': Course_ID, 'fn': firstName, 'ln': lastName, 'em': email})
    if(serverResponse.status_code != 200):  #If not HTTPOk
        print("There was an error while saving your data. Please try again later or use the app.")
    else:
        print("Your profile was saved successfully. Have a good course !")

        
# Initial setting : set the course ID
Course_ID = input("Please enter the course ID: \n")
print("Card reader set up with course id " + Course_ID + ".")
print("Student cards can now be scanned.")
helpers.displayQRCode(Course_ID)

#General loop to keep checking for a card
try:
    while True:
        result = str(subprocess.run(['pm3', '-c', 'hf legic reader'], capture_output=True))
        
        # Check that the result from proxmark contains the MSN number (or if it failed)
        if(result.find("MSN: ") != -1):

            # If we have an MSN, make sure we didn't read it shortly before
            currentMSN = result[408:416]
            print("MSN : " + currentMSN)
            if(currentMSN != lockedMSN):
                lockedMSN = currentMSN
                
                handleOnlyMSN(currentMSN)
        else:
            noCardCounter += 1
            if(noCardCounter > 3600): #It's been an hour, reset the lock (to avoid a single student using his card twice being blocked)
                lockedMSN = ""

        time.sleep(1)


except KeyboardInterrupt:
    print(' interrupted!')

