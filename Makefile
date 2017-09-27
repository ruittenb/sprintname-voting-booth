
NODE_PIDS=$$(/bin/ps -o user,pid,args -t `tty` | awk '$$3 ~ /[n]ode/ { print $$2 }')

restart:
	make stop
	make start

stop:
	-kill -TERM $(NODE_PIDS) && sleep 1 && \
	-kill -QUIT $(NODE_PIDS) && sleep 1 && \
	-kill -KILL $(NODE_PIDS)

start:
	yarn start

.PHONY: stop start restart
