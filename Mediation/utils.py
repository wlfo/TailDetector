from subprocess import PIPE, Popen


class Utils:
    # Return stdout of commandline result
    @staticmethod
    def cmdline(command):
        process = Popen(
            args=command,
            stdout=PIPE,
            shell=True
        )

        out, err = process.communicate()

        return out
        # return process.communicate()[0]
