import sys
import os
    
dockerImage = "aptero-janus"
registry = "registry.aptero.co"
c = os.system

if(sys.argv[1] == "build"):
    os.system("docker build -t "+dockerImage+" .")
    
elif(sys.argv[1] == "exec"):
    os.system("@docker run -p 80:80 -p 8088:8088 -p 8188:8188 --name=\"janus\" -t "+dockerImage+"")
   
if(sys.argv[1] == "publish"):
    version = sys.argv[2]
    c("docker build -t "+dockerImage+" .") 
    c("docker login")
    c("docker tag "+dockerImage+":latest "+registry+"/"+dockerImage+":latest")
    c("docker push "+registry+"/"+dockerImage+":latest")

    c("docker tag "+dockerImage+":latest "+registry+"/"+dockerImage+":"+version)
    c("docker push "+registry+"/"+dockerImage+":"+version)
    
else:
    print("invalid usage");