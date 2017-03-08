# Bootstrap for Java, Gradle, Jersey, and Jetty

This project contains a shell script that spins up a bootstrapped Java, Gradle, Jersey, Jetty hello world server. It's done generically so you can name your base resource package and project names. That way you don't have to fidget in your IDE to remove occurrences of another dev's name all over the place.

Dependencies: Java, Gradle, a bash shell, and a developer who's eager to start developing.

Usage:


```shell
$ sh ./java-hello-world-creator.sh

```
You'll be prompted to enter a project name and default resource package name. Once entered, the script handles all of the path and file generation and will spin up a Jetty server. Access the default endpoint here:

__http://localhost:8080/rest/helloworld__

Expected response:

__Hello world!__

Happy coding!
