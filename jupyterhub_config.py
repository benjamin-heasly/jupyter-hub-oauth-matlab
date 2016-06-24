# Configuration file for Jupyter Hub

c = get_config()

# Path to SSL certificate and key
c.JupyterHub.ssl_key = '/srv/oauthenticator/ssl/ssl.key'
c.JupyterHub.ssl_cert = '/srv/oauthenticator/ssl/ssl.crt'

# Logging
c.JupyterHub.log_level = 'DEBUG'

# Shared notebooks
c.Spawner.notebook_dir = 'toolboxes/notebooks'
c.Spawner.args = ['--NotebookApp.default_url=/notebooks']

from jupyterhub.spawner import LocalProcessSpawner
from tornado import gen
from subprocess import call

class MySpawner(LocalProcessSpawner):
    @gen.coroutine
    def start(self):
        # create the notebook director in the users's home
        user_notebook_dir = '/home/' + self.user.name + '/' + self.notebook_dir
        call(['mkdir', '-p', user_notebook_dir])
        call(['chown', 'root:jupyter', user_notebook_dir])
        call(['chmod', '775', user_notebook_dir])

        # start matlab so that startup.m can fetch notebooks
        call(['matlab', '-nosplash', '-nodesktop', '-r', 'exit'])

        # proceed with normal startup
        LocalProcessSpawner.start(self)
        
c.JupyterHub.spawner_class = MySpawner

# OAuth and user configuration
c.JupyterHub.authenticator_class = 'oauthenticator.LocalGoogleOAuthenticator'

c.LocalGoogleOAuthenticator.create_system_users = True
c.Authenticator.add_user_cmd = ['adduser', '--force-badname', '-q', '--gecos', '""', '--ingroup', 'jupyter', '--disabled-password']

c.Authenticator.whitelist = whitelist = set()
c.Authenticator.admin_users = admin = set()


import os
import sys

join = os.path.join

here = os.path.dirname(__file__)
root = os.environ.get('OAUTHENTICATOR_DIR', here)
sys.path.insert(0, root)

with open(join(root, 'userlist')) as f:
    for line in f:
        if not line:
            continue
        parts = line.split()
        name = parts[0]
        whitelist.add(name)
        if len(parts) > 1 and parts[1] == 'admin':
            admin.add(name)

c.LocalGoogleOAuthenticator.client_id = os.environ['OAUTH_CLIENT_ID']
c.LocalGoogleOAuthenticator.client_secret = os.environ['OAUTH_CLIENT_SECRET']
c.LocalGoogleOAuthenticator.oauth_callback_url = os.environ['OAUTH_CALLBACK_URL']


