
# Aimware-Online-Radar
Web app for rendering an online radar for CS:GO + lua script for Aimware.net


<img src="https://user-images.githubusercontent.com/62262011/196010163-ea4e235b-fd92-4a2f-bd2a-5d7ddda31f03.jpg" width=500 height=500>

### Installation commands

    git clone https://github.com/HITMANek210/Aimware-Online-Radar.git
    cd Aimware-Online-Radar
    pip install -r requirements.txt
    gunicorn --bind=0.0.0.0:80 --worker-class eventlet -w 1 flaskapp:app

### Troubleshooting - ImportError: cannot import name 'ALREADY_HANDLED' from 'eventlet.wsgi'

To fix this error uninstall gunicorn and install it by running this command:

    pip install https://github.com/benoitc/gunicorn/archive/refs/heads/master.zip#egg=gunicorn==20.1.0
    
More about this issue here:
https://github.com/benoitc/gunicorn/pull/2581#issuecomment-994198667
