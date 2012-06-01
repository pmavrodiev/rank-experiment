'''
Created on Feb 22, 2012

@author: tessonec
'''

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import urlparse, cgi



class BaseHandler(BaseHTTPRequestHandler):
    
    def do_GET(self):
        parsed_path = urlparse.urlparse(self.path)
        message = """<html>GET message <br> 
        <form action="http://localhost:8081" method="post">
           Type the applet's name: <input type="text" name="ctapplet"/>
           <input type="submit" value="send"/><br/>
        </form>"""

        message += '\n <br> '.join([
                'CLIENT VALUES:',
                'client_address=%s (%s)' % (self.client_address,
                                            self.address_string()),
                'command=%s' % self.command,
                'path=%s' % self.path ] )
        
        message+= " </html>"

        self.send_response(200)
        self.end_headers()
        self.wfile.write(message)
        return

    def do_POST(self):
        parsed_path = urlparse.urlparse(self.path)
        message = """
        <html>
        POST message <br> 
        <form action="http://web.sg.ethz.ch/users/tessonec/wip/index.php" method="post">
           Type the applet's name: <input type="text" name="estimated_value"/>
           <input type="submit" value="send"/><br/>
        </form> 
        """
        
        # Parse the form data posted
        form = cgi.FieldStorage(
            fp=self.rfile, 
            headers=self.headers,
            environ={'REQUEST_METHOD':'POST',
                     'CONTENT_TYPE':self.headers['Content-Type'],
                     })
        print dir(form)
        message += str(form)
        
        message += """</html>"""
#        message = '\n'.join([
#                'CLIENT VALUES:',
#                'client_address=%s (%s)' % (self.client_address,
#                                            self.address_string()),
#                'command=%s' % self.command,
#                'path=%s' % self.path,
#                'real path=%s' % parsed_path.path,
#                'query=%s' % parsed_path.query,
#                'request_version=%s' % self.request_version,
#                '',
#                'SERVER VALUES:',   
#                'server_version=%s' % self.server_version,
#                'sys_version=%s' % self.sys_version,
#                'protocol_version=%s' % self.protocol_version,
#                '',
#                ]) 
        self.send_response(200)
        self.end_headers()
        self.wfile.write(message)
        return








#
#
#class BaseHandler(BaseHTTPRequestHandler):
#    
#    def __init__(self):
#        ready = False    
#    
#    def do_is_ready(self):
#        message = str(self.ready)
#        
#        self.send_response(200)
#        self.end_headers()
#        self.wfile.write(message)
#        return
#    
#    
#    def do_estimate(self):
#        form = cgi.FieldStorage(
#            fp=self.rfile, 
#            headers=self.headers,
#            environ={'REQUEST_METHOD':'POST',
#                     'CONTENT_TYPE':self.headers['Content-Type'],
#                     })
#        print dir(form)
#        message += str(form)
#        
#
#
#
#    
#    def do_GET(self):
#        
#        if self.path == "ready":
#            self.do_is_ready()
#        if self.path == "estimate":
#            self.do_estimate()
#            
#        return
#
#
#
#
#    def do_POST(self):
#        if self.path == "estimate":
#            self.do_estimate()
#
#        parsed_path = urlparse.urlparse(self.path)
#        message = """
#        <html>
#        POST message <br> 
#        <form action="http://web.sg.ethz.ch/users/tessonec/wip/index.php" method="post">
#           Type the applet's name: <input type="text" name="estimated_value"/>
#           <input type="submit" value="send"/><br/>
#        </form> 
#        """
#        
#        # Parse the form data posted
#        form = cgi.FieldStorage(
#            fp=self.rfile, 
#            headers=self.headers,
#            environ={'REQUEST_METHOD':'POST',
#                     'CONTENT_TYPE':self.headers['Content-Type'],
#                     })
#        print dir(form)
#        message += str(form)
#        
#        message += """</html>"""
##        message = '\n'.join([
##                'CLIENT VALUES:',
##                'client_address=%s (%s)' % (self.client_address,
##                                            self.address_string()),
##                'command=%s' % self.command,
##                'path=%s' % self.path,
##                'real path=%s' % parsed_path.path,
##                'query=%s' % parsed_path.query,
##                'request_version=%s' % self.request_version,
##                '',
##                'SERVER VALUES:',   
##                'server_version=%s' % self.server_version,
##                'sys_version=%s' % self.sys_version,
##                'protocol_version=%s' % self.protocol_version,
##                '',
##                ]) 
#        self.send_response(200)
#        self.end_headers()
#        self.wfile.write(message)
#        return
#
#
#
#
#

























class GuessServer:
    def __init__(self):
        server = HTTPServer(('localhost', 8081), BaseHandler)
        print 'Starting server, use <Ctrl-C> to stop'
        server.serve_forever()


if __name__ == '__main__':
    gs = GuessServer()
    

