FROM dart:2 AS build

# Install flutter
RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor -v
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files.
RUN mkdir /app/
COPY . /app/

# Set build argument.
ARG API_URL

# Resolve app dependencies and build.
WORKDIR /app/
RUN flutter pub get
RUN flutter build web --dart-define=API_ROOT=${API_URL}

# Set the server startup script as executable
RUN ["chmod", "+x", "/app/server.sh"]

EXPOSE 8080

# Start the web server
ENTRYPOINT [ "/app/server.sh" ]
