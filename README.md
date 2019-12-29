# iris_sub_specie_detection_ai
This iOS app takes length and width of iris flower using AR tech and then uses a prediction via trained ml model in the backend and displays the sub specie of Iris


This is a full tutorial on how I created this iOS app. It has the following phases:-
1. Train and Deploy a model on famous Iris Dataset ( I have used AWS windows server )
2. Create API for that trained model ( used Django for this )
3. create the iOS app. ( I will not discuss the basics of iOS app dev. here but discuss the important codes in detail )

<u>Starting from phase 1.</u>
 
#Train the AI model on Iris Dataset

you can download the Iris Dataset from the link below :-

https://www.kaggle.com/chuckyin/iris-datasets

I have done whole analysis of Iris dataset on Kaggle use the link below to find out :-

https://www.kaggle.com/dharvi/kernel17af289f57

##############################################################################################################################
After this we create the model using below code :-
  - I have used logistic regression :
  - I created the below code and ran it over the AWS windows server so that it "PICKLED" there
  
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.externals import joblib
iris = pd.read_csv("Iris.csv")
Y = iris['label']
X = iris.drop(['label'],axis = 1)
logr = LogisticRegression()

#fit the model on training data
logr.fit(X,Y)

# This line of code below is used to pickle the model.
# This will create a doc with .pkl extension which we can call anywhere as you will see below when I will create the API
joblib.dump(logr, 'iris.pkl')

# now stuff with creating a model is done
#############################################################################################################################

<u> Phase 2. </u>

  - Create a Django App
  - Use the below code to create a url for API as follows
  
  import pandas as pd
  import numpy as np
  from sklearn.externals import joblib
 def iris_detection(request):
    lr = joblib.load('iris.pkl') # this will load the model into memory 
    sepal_length = request.GET['sepal_length']
    sepal_width = request.GET['sepal_width']
    petal_length = request.GET['petal_length']
    petal_width = request.GET['petal_width']
    iris_obj =       {'petal_length':float(petal_length),'petal_width':float(petal_width),'sepal_length':float(sepal_length),'sepal_width':float(sepal_width)}
    iris_df = pd.DataFrame(iris_obj,index=[0])
    prediction = lr.predict(iris_df) # This line provides the required values into the trained model
    return HttpResponse(json.dumps({'prediction':prediction.tolist()}))
    
  ## PLEASE NOTE :- THE iris_detect.py, iris.pkl, Django app all should reside on the server
  
  # This finishes the step for API dev. now is the turn for using that API .
  
  # You can use the API in a web APP / Android App / iOS App
##############################################################################################################################
    
  <u> Phase 3. </u>
  
   - The below code is used to call the API via an iOS AR app
   
              # URLis is the url for the API
              
              Alamofire.request(URLis, method: .get , parameters: parameters).responseJSON(completionHandler: { (response) in
                if response.result.isSuccess{
                    let specie: JSON = JSON(response.result.value!)
                    print(specie["prediction"][0])
                    let alert = UIAlertController(title: "Alert", message: specie["prediction"][0].string, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                                    node.removeFromParentNode()
                                }
                    
                }
            })
            
  # Alamofire is an iOS pod (dependency) you can read about it via link below:-
  
  https://cocoapods.org/pods/Alamofire
  
  # I have also used SwiftyJSON which is also a pod used for converting data into JSON
  
  https://cocoapods.org/pods/SwiftyJSON
 
 
 #############################################################################################################################
 
 # That's it we are finished with the iOS AR App that takes in the input (length and width of Petal, length and width of Sepal) using AR as you can see in the video below. The red dots are rendered using AR that calculate length and width of petals and sepals respectively.
 
 
 
 

