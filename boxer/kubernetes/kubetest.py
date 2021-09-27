# import os
# import luigi
import luigi
from luigi.contrib.kubernetes import KubernetesJobTask


class PerlPi(KubernetesJobTask):
    name = "pi"
    # auth_method = 'service-account'
    max_retrials = 3
    spec_schema = {
        "containers": [{
            "name": "pi",
            "image": "perl",
            "command": ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
        }]
    }

    # defining the two functions below allows for dependency checking,
    # but isn't a requirement
    # def signal_complete(self):
    #     with self.output().open('w') as output:
    #         output.write('')
    #
    # def output(self):
    #     target = os.path.join("/tmp", "PerlPi")
    #     return luigi.LocalTarget(target)
#luigi --module examples.kubernetes_job PerlPi --local-scheduler
luigi.build(tasks=[PerlPi()],
            scheduler_host='localhost')