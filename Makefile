
NODE_PIDS=$$(/bin/ps -o user,pid,args -t `tty` | awk '$$3 ~ /[n]ode/ { print $$2 }')

status:
	@test "$(NODE_PIDS)" && echo Running || echo Stopped

stop:
	if [ "$(NODE_PIDS)" ]; then \
		kill -TERM $(NODE_PIDS) && sleep 1 && \
		kill -QUIT $(NODE_PIDS) && sleep 1 && \
		kill -KILL $(NODE_PIDS); \
	fi

start:
	yarn start

restart:
	make stop
	make start

.PHONY: status stop start restart
