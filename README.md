# Развёртка проекта на локальной машине
1. **RVM**
	
	Для установки потребуется curl,wget.

	`bash < <(curl -k https://rvm.beginrescueend.com/install/rvm)`
1. **Ruby**
	
	`rvm install ruby`
1. **Fetch**

    `git fetch git://github.com/nukah/lanshera-factory.git master && cd lanshera-factory`
1. **Gems**
	
	`rvm use ruby`
	
	`rvm --rvmrc gemset create lanshera`
	
	`echo "rvm use $RUBY_VERSION@lanshera" >> .rvmrc`
1. **Bundle**
	
	`bundle install`