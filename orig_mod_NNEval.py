import numpy as np
import pickle
import time
import os
import nibabel as nib
import sys
import glob

from scipy.io import loadmat
from scipy.io import savemat
import math

#import tensorflow as tf
import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()


#Comment in if there is a GPU/CUDA enabled device
#os.environ["CUDA_VISIBLE_DEVICES"]="0"


def conv_block(x,KERNEL_SIZE, FILTERS):
    x = tf.layers.conv3d(x,FILTERS,KERNEL_SIZE,padding='same')
    return tf.nn.elu(x)

def unet(x,N_CLASS):
    with tf.name_scope('layer1_enc'):
        x1 = conv_block(x,3,16)
        x1 = conv_block(x1,3,16)
        x1 = conv_block(x1,3,16)
        x1p = tf.layers.max_pooling3d(x1, 2, 2)
        print(x1p.shape)
    with tf.name_scope('layer2_enc'):
        x2 = conv_block(x1p,3,32)
        x2 = conv_block(x2,3,32)
        x2 = conv_block(x2,3,32)
        x2p = tf.layers.max_pooling3d(x2, 2, 2)
        print(x2p.shape)
    with tf.name_scope('layer3_enc'):
        x3 = conv_block(x2p,3,64)
        x3 = conv_block(x3,3,64)
        x3 = conv_block(x3,3,64)
        x3p = tf.layers.max_pooling3d(x3, 2, 2)
        print(x3p.shape)
    with tf.name_scope('bottom'):
        x4 = conv_block(x3p,3,128)
        x4 = conv_block(x4,3,128)
        x4 = conv_block(x4,3,128)
        
        x4t = tf.layers.conv3d_transpose(x4,64,3,strides=2,padding='same')
        print('p0')
        print(x4t.shape)
    with tf.name_scope('layer3_dec'):
        x3 = tf.concat((x4t,x3),axis=-1)
        x3 = conv_block(x3,3,64)
        x3 = conv_block(x3,3,64)
        x3 = conv_block(x3,3,64)
        x3t = tf.layers.conv3d_transpose(x3,32,3,strides=2,padding='same')  
        print(x3t.shape)
    with tf.name_scope('layer2_dec'):
        x2 = tf.concat((x3t,x2),axis=-1)
        x2 = conv_block(x2,3,32)
        x2 = conv_block(x2,3,32)
        x2 = conv_block(x2,3,32)
        x2t = tf.layers.conv3d_transpose(x2,16,3,strides=2,padding='same')   
    with tf.name_scope('layer1_dec'):
        x1 = tf.concat((x2t,x1),axis=-1)
        x1 = conv_block(x1,3,16)
        x1 = conv_block(x1,3,16)
        x1 = conv_block(x1,3,16)
        x1 =  tf.layers.conv3d(x1, N_CLASS, 1)  
        return(x1)

#new
#data directory for cnn project
#data_dir='/mnt/jxvs2_02/neil/Striatal_Segmentation/Data_01/'
# outdated - ignore below
cluster=1

#this is the path to the T1 skull-stripped image
testList=[sys.argv[1]]

launch=os.getcwd()

#tf.reset_default_graph()
#os.environ["CUDA_VISIBLE_DEVICES"]="0"    

X = tf.placeholder(tf.float32, shape=[1, 256, 256, 192, 1],   name='X')  #input
pred = unet(X, 6)
new_saver=tf.train.Saver()

sess = tf.Session(config=tf.ConfigProto(log_device_placement=True))

# the below is where the network weights are located provided by user input 
print(sys.argv[3])
new_saver.restore(sess,tf.train.latest_checkpoint(sys.argv[3]))
print("Loaded Weights")


#for i in testList:
#changed below because it did not finish entire list
for i in range(len(testList)): 
#new
    print(i)
    out_dict={}
# we directly import the t1 image here below
    mri=sys.argv[1]

    mri=nib.load(mri)
    mri=mri.get_data()
    print(mri.shape) # original mri dimensions before any transformations

    mri_out=mri
    mri=np.expand_dims(mri,0)
    if mri.shape[-1]!=1:
        mri=np.expand_dims(mri,-1)
    padder1=192-mri.shape[3]
    padder1=np.zeros((mri.shape[1],mri.shape[2],padder1))
    padder1=np.expand_dims(padder1,0)
    padder1=np.expand_dims(padder1,-1)
    mri=np.concatenate((padder1,mri),axis=3)
    print(mri.shape)
    padder2=np.zeros((mri.shape[0],max(0,256-mri.shape[1]),mri.shape[2],mri.shape[3],1))
    mri=np.concatenate((padder2,mri),axis=1)

    padder3=np.zeros((mri.shape[0],mri.shape[1],max(0,256-mri.shape[2]),mri.shape[3],1))
    mri=np.concatenate((padder3,mri),axis=2)
    print(mri.shape)
    outt=np.zeros((mri.shape[0],mri.shape[1],mri.shape[2]))
    b = sess.run(pred,feed_dict={X:mri})
    b=sess.run(tf.nn.softmax(b))
    out_dict['out']=b
    out_dict['mri']=mri_out
    print(os.getcwd())
    savedir=sys.argv[2]
    savemat(savedir,out_dict)
    


print('python script complete.')

