from __future__ import print_function
# import model

import numpy as np
import tensorflow as tf
from flask import Flask, jsonify, render_template, request

from tensorflow.python.platform import gfile
import wget
# import flickrapi
# import PIL.Image
# from IPython.display import Image, display, HTML
# from io import BytesIO
import operator

# if __name__ == '__main__':
#     app.debug = True
#     app.run()

# categories = [  [ 'Beans', 'Legumes'], 
#                 [ 'Beverages', 'beverage' ],
#                 [ 'Breads', 'bread', 'Cereals'],
#                 [ 'Cheese', 'Milk', 'Dairy'],
#                 [ 'Eggs' ],
#                 [ 'Fast Food'],
#                 [ 'Fish', 'Seafood'],
#                 [ 'Fruit' ],
#                 [ 'Meat' ],
#                 [ 'Nuts', 'Seeds' ],
#                 [ 'Pasta', 'Rice', 'Noodles' ],
#                 [ 'Salads', 'salad' ],
#                 [ 'Sauces', 'sauce', 'Spices', 'Spreads' ],
#                 [ 'Snacks', 'snack' ],
#                 [ 'Soups', 'soup' ],
#                 [ 'Sweets', 'Candy', 'Desserts', 'dessert' ],
#                 [ 'Vegetables', 'vegetable' ]
#             ]

def concat(cat):
    catstr = ""
    for elem in cat:
        catstr += elem
    return catstr

# api_key = u'62a1df054a33ec8a6cbacf38b3343175'
# api_secret = u'7ce4101454340005'
# flickr = flickrapi.FlickrAPI(api_key, api_secret, format='parsed-json')

# def showarray(a, fmt='jpeg'):
#     a = np.uint8(np.clip(a, 0, 1)*255)
#     f = BytesIO()
#     PIL.Image.fromarray(a).save(f, fmt)
#     display(Image(data=f.getvalue()))

def readcategories(txt):
    f = open( txt, "r" )
    a = []
    for line in f:
        a.append(line.rstrip())
    return a
  
def topnwprobs(y_pred, categories, n = 5):
    y_dict = dict(zip(y_pred, range(len(y_pred))))
    sorted_y = sorted(y_dict.items(), key=operator.itemgetter(0), reverse=True)
    result = []
    for i in range(n):
        category = categories[sorted_y[i][1]]
        result.append([category, 100 * sorted_y[i][0]])
#         print("%s - %.1f%%" % (category, 100 * sorted_y[i][0]))
    return result

def concat(cat):
    catstr = ""
    for elem in cat:
        catstr += elem
    return catstr


def getcategorytensor(concategory, decod_jpg):
    model_path = "/tmp/output_%s_graph.pb" % concategory
    labels_path = "/tmp/output_%s_labels.txt" % concategory
    labels = readcategories(labels_path)
    with tf.gfile.FastGFile(model_path, 'rb') as f:
        graph_sub_def = tf.GraphDef()
        graph_sub_def.ParseFromString(f.read())    

    softmax_sub_tensor = tf.import_graph_def(
        graph_sub_def,
        input_map={'DecodeJpeg:0': decod_jpg},
        return_elements=['final_result:0'])
    return {"tensor": softmax_sub_tensor, "labels": labels}

model_cat_fn = 'output_cat_new_graph.pb'
labels_cat_fn = 'output_cat_new_labels.txt'

model_all_fn = 'output_all_graph.pb'
labels_all_fn = 'output_all_labels.txt'

labels_cat = readcategories(labels_cat_fn)
labels_all = readcategories(labels_all_fn)

# a = dict(zip(range(len(labels_cat)), labels_cat))
# sorted_y = sorted(a.items(), key=operator.itemgetter(1))
# sy = np.array(sorted_y)
# vals = np.array(sy[:,0])
# laborder = dict(zip(range(len(vals)), vals.astype(int)))

graph = tf.Graph()
sess = tf.InteractiveSession(graph=graph)

with tf.gfile.FastGFile(model_cat_fn, 'rb') as f:
    graph_cat_def = tf.GraphDef()
    graph_cat_def.ParseFromString(f.read())

with tf.gfile.FastGFile(model_all_fn, 'rb') as f:
    graph_all_def = tf.GraphDef()
    graph_all_def.ParseFromString(f.read())

jpg_data = tf.placeholder(tf.string, shape=[])
decoded_jpg = tf.image.decode_jpeg(jpg_data, channels=3)

softmax_cat_tensor = tf.import_graph_def(
    graph_cat_def,
    input_map={'DecodeJpeg:0': decoded_jpg},
    return_elements=['final_result:0'])

softmax_all_tensor = tf.import_graph_def(
    graph_all_def,
    input_map={'DecodeJpeg:0': decoded_jpg},
    return_elements=['final_result:0'])

# tensorinfo = {}
# for cat in categories:
#     tensorinfo[concat(cat).lower()] = getcategorytensor(concat(cat), decoded_jpg)

# webapp
app = Flask(__name__)


@app.route('/api/mnist', methods=['POST'])
def mnist():
#     url = 'https://farm%s.staticflickr.com/%s/%s_%s.jpg' % (farm, server, photo_id, secret)
    # filename = wget.download(url)
    inputData = request.json
    fileUrl = inputData["url"]
    # print(fileUrl)
    filename = wget.download(fileUrl)
    # filename = 'test.jpg'
    # print(filename)
    image_data = tf.gfile.FastGFile(filename, 'rb').read()
    y_pred_cat = np.squeeze(sess.run(softmax_cat_tensor, {jpg_data: image_data}))
    y_pred_all = np.squeeze(sess.run(softmax_all_tensor, {jpg_data: image_data}))

    # print(y_pred_cat)
#         y_pred = np.squeeze(sess.run(softmax_tensor, {jpg_data: image_data}))
#         if(y_pred[0] > 0.6):
#         print(y_pred[0])
    topcats = topnwprobs(y_pred_cat, labels_cat, 3)
    topall  = topnwprobs(y_pred_all, labels_all, 20)
    # print(topcats)
    # predictions = []
    # print(topcats)
    # img0 = PIL.Image.open(filename)
    # img0 = np.float32(img0)
    # showarray(img0/255.0)        

#         for i in range(len(topcats)):
#             [tens, labl] = [tensorinfo[topcats[i][0]]["tensor"], tensorinfo[topcats[i][0]]["labels"]]
#             class_prob = topcats[i][1]
#             y_pred_sub = np.squeeze(sess.run(tens, {jpg_data: image_data}))
#             topsubcat = topnwprobs(y_pred_sub, labl, 3)
#             for val in topsubcat:
#                 predictions.append([topcats[i][0], class_prob, val[0], val[1], 1.5 * class_prob + val[1]])
#         sorted_preds = sorted(predictions, key=operator.itemgetter(4), reverse=True)
#         for val in sorted_preds:
#             if(val[4] > 20):
#                 print( "%s : %.1f%%, %.1f%%" % (val[2], val[1], val[3]))

    # input = ((255 - np.array(request.json, dtype=np.uint8)) / 255.0).reshape(1, 784)
    # output1 = regression(input)
    # output2 = convolutional(input)
    

    catnames = list(np.array(topcats)[:,0])
    allnames = list(np.array(topall)[:,0])
    return jsonify(results=[catnames, allnames])#[output1, output2])


@app.route('/')
def main():
    return render_template('index.html')
