import qrcode
from PIL import Image
from datetime import date

## Validation methods (loops that force a valid input)

def inputName(n: str):  # Name must be at least two chars long and alphanumeric
    returnValue = input("Please type your " + n + " name and press enter:")
    while(len(returnValue) < 2 or not returnValue.isalpha()):
        returnValue = input("This name is not valid. Please try again:")
    
    return returnValue

def inputEmail():  # email must be at least five chars long, use ascii chars only and containt an @ and a .
    returnValue = input("Please type your full email and press enter:")
    while(len(returnValue) < 5 or not returnValue.isascii() or "@" not in returnValue or "." not in returnValue):
        returnValue = input("This email is not valid. Please try again:")
    
    return returnValue

def inputStudentNumber():   # student number must be numeric only (once the dashes are removed) and 8 chars long exactly)
    returnValue = input("This number looks like xx-xxx-xxx. Please type it and press enter :")
    while (len(returnValue.replace("-", "")) != 8 or not returnValue.replace("-", "").isnumeric()):
        returnValue = input("This student number is not valid. Please try again:")

    return returnValue.replace("-", "")

## QR code method  : generates a qr code, and opens it in a small window.
def displayQRCode(courseID: int):
    img = qrcode.make(f"CVUFR!{zeroPad(courseID, 5)}?{date.today().strftime('%y%m%d')}")
    img.save(f"qr_{courseID}.png")
    Image.open(f"qr_{courseID}.png").show()

## Helper method to return a zero-padded string from a number
def zeroPad(nbr: int, wantedLength: int):
    returnValue = str(nbr)
    assert len(returnValue) <= wantedLength
    return (wantedLength - len(returnValue)) * "0" + returnValue
    