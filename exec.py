import sys
import os
    
dockerImage = "aptero-janus"

if(sys.argv[1] == "build"):
    os.system("docker build -t "+dockerImage+" .")
    
elif(sys.argv[1] == "exec"):
    os.system("@docker run -p 80:80 -p 8088:8088 -p 8188:8188 --name=\"janus\" -t "+dockerImage+"")

else:
    print("invalid usage");