# calloutd
# Aysnchronized call implementation
# Author: Jackie.ju@gmail.com
#

require 'rubygems'
require 'launch_job'
require 'rubyutility'
require 'json'
=begin
class Callouts
    def add(obj, method, delay=0, p=nil)
        @s = "" if !@s
        @s+= gen_callout_string(obj, method, delay, p)+"\n"
    end

    def save
        dir = "#{g_FILEROOT}/globaldata/q"
        fname="#{dir}/#{Time.now.to_f}.callout"
        save_to_file(@s, fname) if @s && @s != ""
    
    end

end
=end

class CallOut
    @@debug = false
    @@callout_fs_root = "."
    class << self
        def fs_root
            return @@callout_fs_root if @@callout_fs_root
            return "."
        end
        def set_fs_root(dir)
            @@callout_fs_root = dir
        end
        def set_debug(_d)
            @@debug = _d
        end
        def debug?
            @@debug
        end
        # need to be override
        def obj_id(obj)
            return obj.to_s
        end
        def gen_callout_string(oid, method, delay=0, p=nil)
           
            s = "#{oid}|:|#{method.to_s}|:|#{delay}|:|#{p.to_json}"
            p "callout str:#{s}" if debug?
            return s
        end
        
        def callout(obj, method, delay=0, *p)
             oid = ""
                if obj !=nil
                    if obj.class == String
                        oid = obj
                    else
                        # oid = obj.obj_id
                        oid = obj_id(obj)
                    end
                end
                
            s = gen_callout_string(oid, method, delay, p)
            fname="#{fs_root}/#{Time.now.to_f}_#{oid}_#{method}.callout"
            save_to_file(s, fname)
            dir = get_dir(fname)
           
            p "save callout to #{fname}"
        end
        
        def remove_callout(obj, n)
            return if !obj && !n
            
            if obj == nil
                s_obj = "*"
            else
                if obj.class == String
                    s_obj = "#{obj}"
                else
                    s_obj = obj_id(obj)
                end
            end
            
            if n == nil
                s_n = "*"
            else
                s_n = "#{n}"
            end
            
            s = "#{fs_root}/_#{s_obj}_#{s_n}.callout"
            
            Dir[s].each{|filename|
                File.delete(filename)
            }
            
        end


        
        def pick_callouts(&block)
            # p "===>pick_callouts"
            dir = "#{fs_root}/*.callout"
            files = Dir[dir].sort_by{|c| 
                File.stat(c).ctime #sort by change time
            }
            
            return if !files or files.size < 1
            
            files.each{|fname|
                # fname = nil
                # if files.size > 0
                #     fname =  files.first
                # end
                # p "===>pick_callouts1:#{fname}"
                # p files.first
                # p  File.stat(files.first).ctime
                #p files.last # newset
                #File.stat(files.last).ctime

                return if !fname
                pure_fname = fname.split("/").last
                f_tm = pure_fname.gsub(".callout", "").to_f
                p "tm:#{f_tm}" if debug?
                begin
                  p "fname:#{fname}" if debug?
                   if FileTest::exists?(fname)   

                       data = nil
                       open(fname, "r+") {|f|
                           str = f.read
                           if str
                               ar = str.split("|:|")
               
                               data = {
                               :tm=>f_tm,
                               :oid=>ar[0],
                               :method=>ar[1],
                               :delay=>ar[2].to_i,

                            }
                                if ar[3] 
                                    data[:p] = JSON.parse(ar[3])
                                end
                           end
                    
                            # TODO maybe need reserve error callouts
                           if data ==nil || data[:method] == nil
                               p "delete callout file #{fname}" if debug?
                               File.delete(fname)
                               next
                           end
                       
                           if data 
                               # p "done21"
                               r = yield(data)
                               # p "done22"
                               if r== true
                                   p "delete callout file #{fname}" if debug?
                                   
                                   File.delete(fname) 
                               end
                           else
                               p "delete callout file #{fname}" if debug?
                               
                               File.delete(fname) 
                           end
                           
                           # File.delete(fname)
                           break
               
               
                    }
                    end
                rescue Exception=>e
                    File.delete(fname) 
                    p "err!:#{e}"
                    print e.backtrace.join("\n")
                    
        
                end
            }
        end


    
        # to be overrite
        def get_obj(oid)
        end
    end

end
def calloutd
        CallOut.pick_callouts(){|data|
            p "data:#{data.inspect}" if CallOut.debug?
            if data[:method]
                if data[:delay] && Time.now.to_f - data[:tm] < data[:delay]
                    next false
                end
                p "oid=>#{data[:oid]}"if CallOut.debug?
                if (data[:oid] && data[:oid] !="")
                    n = CallOut.get_obj(data[:oid])
                    p "object=>#{n}"if CallOut.debug?
                    
                    if n && n.respond_to?(data[:method])
                        begin
                            p "==>callout #{data[:method]} on object #{n}, params:#{data[:p]}" if CallOut.debug?
                            if data[:p]
                                n.send(data[:method])
                            else
                                n.send(data[:method], *data[:p])
                                
                            end
                        rescue Exception=>e
                            p "err!:#{e}"
                            print e.backtrace.join("\n")
                        end
                        next true
                    end
                else
                    begin
                        p "==>callout #{data[:method]}, params:#{data[:p]}" if CallOut.debug?
                        
                        if data[:p]
                            Object.send(data[:method])
                        else
                            Object.send(data[:method], *data[:p])

                        end
                                
                    rescue Exception=>e
                        err(e)
                    end
                    next true
                end
            end
            next true
        }
        
        
    
end
def launch_calloutd(_hash=nil)
    if _hash
        if _hash[:fn] ==nil
            _hash[:fn] = "calloutd"
        end
        if _hash[:ms] ==nil
            _hash[:fn] = 0.01
        end
    else
        _hash = {
            :fn=>"calloutd",
            :ms=>0.01
        }
    end
    launch_job_with_hash(_hash)
end

=begin
# test
class CallOut
    def self.get_obj(oid)
        p "get_obj"
        return nil
    end
end
def testcallout1()
    p "===>testcallout1"
end
def testcallout(p1, p2)
    p "===>#{p1}===>#{p2}"
end
# launch_calloutd
# sleep(3)
CallOut.callout(nil, :testcallout1, 3)
# CallOut.callout(nil, :testcallout, 0, 1111, 2222)
    calloutd
    sleep(1)
    calloutd
    sleep(1)
    calloutd
    sleep(1)
    calloutd
    sleep(1)
=end
