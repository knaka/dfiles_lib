# --------------------------------------------------------------------
# Ruby
# --------------------------------------------------------------------

ENV RBVER 2.1.4

RUN apt-get install -y rbenv
# Install these only for requirements.
RUN apt-get install -y ruby-build && dpkg --remove ruby-build
# Remove executables.
RUN dpkg -L ruby | grep bin/ | xargs rm

RUN apt-get install -y git
# For newer versions of Ruby.
RUN git clone https://github.com/sstephenson/ruby-build.git && \
    cd ruby-build && \
    ./install.sh

# $HOME should be changed to build with rbenv
ENV HOME /home/unpriv/
WORKDIR $HOME

RUN rbenv install --verbose $RBVER
ENV PATH $HOME/.rbenv/shims:$PATH
RUN rbenv global $RBVER

RUN echo "gem: --no-rdoc --no-ri" >> .gemrc

ENV HOME /root
WORKDIR $HOME

RUN echo "gem: --no-rdoc --no-ri" >> .gemrc

# --------------------------------------------------------------------
# Rails
# --------------------------------------------------------------------

ENV RAILS_VER 4.1.8

RUN apt-get install -y libmysqld-dev
RUN apt-get install -y libpq-dev

ENV HOME /home/unpriv/
WORKDIR $HOME

RUN gem install bundler && rbenv rehash

EXPOSE 3000
ENV APPNAME appapp

ifdef([[DEVEL]], [[
	ifdef([[INITIAL_IMAGE]], [[
		RUN gem install rails -v "$RAILS_VER" && rbenv rehash
		RUN rails new $APPNAME
		WORKDIR $APPNAME
		RUN mv config/database.yml config/database.yml.sample
		RUN git init
		RUN echo "gem 'execjs'" >> Gemfile # http://goo.gl/slkoin
		RUN echo "gem 'therubyracer', :platforms => :ruby" >> Gemfile
		RUN echo "gem 'mysql2'" >> Gemfile
		RUN echo "gem 'pg'" >> Gemfile
		RUN bundle install && rbenv rehash
		RUN git add .
		RUN cp config/database.yml.sample config/database.yml
		RUN echo config/database.yml >> .gitignore
		RUN git add .gitignore
		RUN rake db:migrate
		RUN git add db/schema.rb
		WORKDIR $HOME
		RUN mv $APPNAME $APPNAME.bak
	]], [[
		ENV HOME /home/unpriv/$APPNAME.bak
		RUN mkdir -p $HOME
		WORKDIR $HOME
		ADD Gemfile $HOME/Gemfile
		ADD Gemfile.lock $HOME/Gemfile.lock
		RUN bundle install && rbenv rehash
	]])
]], [[
	ADD appapp.tar.bz2 $HOME/$APPNAME/
	RUN cd $APPNAME && bundle install && rbenv rehash
	RUN cp $APPNAME/config/database.yml.sample $APPNAME/config/database.yml
]])

ENV HOME /root/
WORKDIR $HOME
