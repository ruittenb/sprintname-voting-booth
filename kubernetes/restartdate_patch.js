const patch = {
    spec: {
        template: {
            metadata: {
                labels: {
                    restartdate: `${new Date().getTime()}`
                }
            }
        }
    }
}

console.log(JSON.stringify(patch)) // eslint-disable-line no-console
