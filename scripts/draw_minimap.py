import os, json
from PIL import Image
from PIL import ImageDraw

size = (15000, 15000)
mode = "1"
color = 0
img = Image.new(mode, size, color)
imgDraw = ImageDraw.Draw(img)
path = "map.jpg"

def get_rect(x, y):
    x = 15000 - x
    x_ = x
    y_ = y
    if x > 3:
        x_ = x - 3
    if y > 3:
        y_ = y - 3
    return [(x, y), (x_, y_)]

def draw_states(states):
    for items in states:
        x = items['position']['x']
        y = items['position']['y']
        rectangle = get_rect(x, y)
        imgDraw.rectangle(rectangle, 1, 1)

def draw_data(data):
    for items in data['data']['blueTeam']['players']:
        draw_states(items['playerStates'])
    for items in data['data']['redTeam']['players']:
        draw_states(items['playerStates'])

dir_path = os.path.dirname(os.path.realpath(__file__))

for filename in os.listdir(dir_path):
    if(filename.endswith(".json")):
        with open(filename) as data_file:
            data = json.load(data_file)
            draw_data(data)

del imgDraw

img.save(path, "JPEG")
