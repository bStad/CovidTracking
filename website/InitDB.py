# This file creates the DB automatically if it is not present already.

from tortoise import Tortoise
from models import People, Courses, Attendance
import asyncio

DBPath = "DB.sqlite3"

async def first_time_init(DBPath):
    print("[InitDB] Attempting tortoise init")
    await Tortoise.init(db_url="sqlite://" + DBPath, modules={"models" : ["__main__"]})
    print("[InitDB] DB initialized, generating schemas")
    await Tortoise.generate_schemas()
    
    #Add mock data into the DB for testing/visualization
    print("[InitDB] Schemas generated, adding mock data")
    JP = await People.create(Surname="Jean Pierre", Name="Foucault", 
        Student_Number=16322112, Email="JPF@fakemail.org")

    Bill_Gates = await People.create(Surname="Bill", Name="Gates",
        Student_Number=17404505, Email="BillGates@fakemail.org")

    Marc = await People.create(Surname="Marc", Name="Dupuis", 
        Student_Number=18317099, Email="MarcD@fakemail.org")
    

    Management = await Courses.create(Professor_ID=Bill_Gates.Person_ID, 
        Course_name="Management 101")
    

    Attendance1 = await Attendance.create(Date_time="2021-03-05", 
        Course_ID=Management.Course_ID, )
    
    await JP.Attended.add(Attendance1)
    await Marc.Attended.add(Attendance1)
    await Bill_Gates.Attended.add(Attendance1)
    
    print("[InitDB] Mock data inserted into the DB")     
    await Tortoise.close_connections()  

    print("[InitDB] Connection closed, generation is done")

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(first_time_init(DBPath=DBPath))