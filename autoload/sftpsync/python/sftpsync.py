# -*- coding: UTF-8 -*-

# ============================================================================
# File:        sftpsync.py
# Description: Upload files to remote server via sftp
# Author:      Filip Dąbek <filedil@gmail.com>
# Website:     https://github.com/filedil
# License:     MIT License
# ============================================================================

import os
import paramiko
import posixpath
import re
import sys
import traceback
import vim

class SftpSync(object):
	connections = {}

	def __init__(self):
		try:
			self.host_keys_file = os.path.expandvars(vim.eval('g:sftpsync_host_keys_file'))
			self.host_keys = paramiko.util.load_host_keys(os.path.expandvars(vim.eval('g:sftpsync_host_keys_file')))
		except FileNotFoundError:
			pass

		try:
			self.pkey = paramiko.RSAKey.from_private_key_file(os.path.expandvars(vim.eval('g:sftpsync_private_key_file')))
		except FileNotFoundError:
			self.pkey = None

		self.socket_timeout = int(vim.eval('g:sftpsync_socket_timeout'))
		self.debug = False


	def escapeQuote(self, str):
		return "" if str is None else str.replace("'", "''")


	def printError(self, error):
		if type(error) != list:
			error = [error]

		vim.command("echohl Error | redraw")
		vim.command("echom 'SftpSync failed:'")
		for line in error:
			vim.command("echom '%s'" % self.escapeQuote(str(line)))
		vim.command("echohl None")


	def printDebug(self, message):
		if self.debug:
			print("DEBUG: %s" % message)


	def setStatus(self, status):
		vim.command("let b:sftpsync_status = '{}'".format(status))


	def purgeCache(self):
		self.connections = {}


	def upload(self, filename, target):
		if not os.path.isfile(filename):
			self.printError("Filename is not a regular file")
			self.setStatus("error")
			return False

		for (project_name, project) in vim.eval('g:sftpsync_projects').items():
			try:
				(destination, count) = re.subn(project['source'], project['destination'][target]['directory'], filename, flags=re.IGNORECASE)
				destination_dir = os.path.dirname(destination) + '/'
			except KeyError:
				self.printError("Project '%s' doesn't have target '%s'" % (project_name, target))
				self.setStatus("error")
				return False

			if count > 0:
				# raise Exception('test')
				config = project['destination'][target]

				for host in config['hosts']:
					(username, hostname) = host.rsplit('@', 1)
					try:
						(hostname, port) = hostname.rsplit(':', 1)
					except ValueError:
						port = 22

					try:
						(username, password) = username.split(':', 1)
					except ValueError:
						password = None

					try:
						# raise Exception('test')
						cache_key = '{}_{}'.format(project_name, host)

						if cache_key in self.connections and self.connections[cache_key][0].get_transport().is_active():
							(t, sftp) = self.connections[cache_key]
						else:
							if not self.pkey and not password:
								raise FileNotFoundError('Neither private key file nor password is set, please adjust configuration')

							t = paramiko.SSHClient()

							if self.host_keys_file:
								t.load_host_keys(self.host_keys_file)
							else:
								t.set_missing_host_key_policy(paramiko.AutoAddPolicy())

							t.connect(
								hostname,
								port=port,
								username=username,
								password=password,
								pkey=self.pkey,
								timeout = self.socket_timeout,
							)
							sftp = t.open_sftp()

							self.connections[cache_key] = (t, sftp)

						try:
							sftp.put(filename, destination)
						except FileNotFoundError:
							# make all missing directiories
							path = "/".join(destination_dir.split('/')[0:len(project['destination'][target]['directory'].split('/'))])
							subdirs = destination_dir.split('/')[len(project['destination'][target]['directory'].split('/')):-1]

							for subdir in subdirs:
								path = posixpath.join(path, subdir)

								try:
									sftp.listdir(path)
								except FileNotFoundError:
									sftp.mkdir(path)

							sftp.put(filename, destination)

					except Exception:
						self.printError(traceback.format_exc().split('\n'))
						self.setStatus("error")
						return False

				self.setStatus("done")
				return True
			else:
				self.printDebug("Filename '%s' doesn't match project '%s'" % (filename, project_name))

		self.printError("No project was matched for filename '%s'" % (filename))
		self.setStatus("error")
		return False


sftpSync = SftpSync()
__all__ = ['sftpSync']

