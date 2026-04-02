# Stage 1: Build
FROM openjdk:17-jdk-slim as builder

WORKDIR /app
COPY Tokenring/src ./src
COPY Tokenring/build.xml ./
COPY Tokenring/nbproject ./nbproject
COPY Tokenring/manifest.mf ./

# Install Ant
RUN apt-get update && apt-get install -y ant && rm -rf /var/lib/apt/lists/*

# Build the project
RUN ant clean build

# Stage 2: Runtime
FROM openjdk:17-jre-slim

WORKDIR /app

# Copy built classes from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/build/classes ./build/classes

# Install GUI support for servers (if needed for headless mode)
RUN apt-get update && apt-get install -y xvfb x11-utils && rm -rf /var/lib/apt/lists/*

# Default to Server1, can be overridden
ENV SERVER_NUM=1
ENV JAVA_OPTS="-Djava.awt.headless=true"

EXPOSE 5000-5005

CMD ["sh", "-c", "java ${JAVA_OPTS} -cp build/classes Server${SERVER_NUM}.Server${SERVER_NUM}"]
