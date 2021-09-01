from aiohttp import web
from models import People, Courses, Attendance
import handlers

templates_path = "HTML_templates/"

# Helper method
async def HTML_Response(template):
    return web.Response(text=open(file=(templates_path + template + ".html")).read(), content_type='text/html') 

async def HTML_text(template):
    return open(file=(templates_path + template + ".html")).read()

async def Save_success_response(type):
    response = await HTML_text("html_start") + "<h1>The " + type + " was successfully saved.</h1>" + await HTML_text("html_end")
    return web.Response(text=response, content_type='text/html')

# Page requests

async def index(request):
    return await HTML_Response("index")

async def people(request):
    people = await People.all()
    return web.json_response({"People": [str(person) for person in people]})

async def add_person(request):
    return await HTML_Response("add_person")

async def courses(request):
    courses = await Courses.all()
    return web.json_response({"Courses": [str(course) for course in courses]})

async def add_course(request):
    return await HTML_Response("add_course")

async def attendances(request):
    attendances = await Attendance.all()
    return web.json_response({"Attendances": [str(att) for att in attendances]})

async def add_attendance(request):
    return await HTML_Response("add_attendance")

async def signal(request):
    return await HTML_Response("signal")

async def contact(request):
    return await HTML_Response("contact")

async def stats(request):
    return await HTML_Response("stats")

async def save_by_QR(request):
    data = await request.post()
    # Split data into two dicts, one for each handler
    person_id = await handlers.trySaveNewPerson(data)
    # Create the new dict for saving the attendance
    data2 = {'ci' : data['ci'], 'dt' : data['dt'], 'at' : str(person_id)}
    await handlers.trySaveNewAttendance(data2)
    return web.HTTPOk()

async def proxmark_interface(request):
    data = await request.post()
    return await handlers.handle_proxmark_data(data)

async def save_person(request):
    data = await request.post()
    await handlers.trySaveNewPerson(data)
    return await Save_success_response("profile")

async def save_course(request):
    data = await request.post()
    await handlers.trySaveNewCourse(data)
    return await Save_success_response("course")

async def save_attendance(request):
    data = await request.post()
    await handlers.trySaveNewAttendance(data)
    return await Save_success_response("attendance")
