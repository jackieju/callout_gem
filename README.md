# calloutd
Ruby asynchronized call by launching jobs to execute call persist to FS queue.
Passed on ruby 1.8.7

install
===

dependency:
rubyutility
ps_grep
launch_job

install calloutd from git

    git clone https://github.com/jackieju/calloutd_gem.git
    cd calloutd_gem
    build callaoutd.gemspec
    gem install *.gem
    
Usage
===
1. Asynch call to method

        def testcallout1()
            p "testcallout1"
        end
        def testcallout(p1, p2)
            p "#{p1},{p2}"
        end

        # launch jobs
        launch_calloutd

        # call after 3 minutes
        CallOut.callout(nil, :testcallout1, 3)
        
        # call as soon as possible
        CallOut.callout(nil, :testcallout, 0, 1111, 2222)

2. Asynch to instance method of object

        # override get_obj
        class CallOut
            def self.get_obj(oid)
                p "get_obj"
            return YouClass.new
            end
        end
3. 
