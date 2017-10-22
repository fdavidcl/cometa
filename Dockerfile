# Use an official Ruby runtime as a parent image
FROM ruby:2.4.2-onbuild

# Set the working directory to /app
# WORKDIR /app

# Copy the current directory contents into the container at /app
# ADD . /app

# Install any needed packages specified in Gemfile
# RUN bundle

# Make port 80 available to the world outside this container
EXPOSE 443

# Define environment variable
# ENV NAME World

# Run app.py when the container launches
CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "-P", "443"]
