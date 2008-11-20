begin
  require "continuation"
rescue LoadError
end

module DynamicWind
  VERSION = '1.0.0'

  Stack = Struct.new(:fst, :snd, :next)

  alias __callcc_orig callcc

  def callcc
    mark = __top
    __callcc_orig do |ctn|
      yield(proc {|*ret| __switch(mark); ctn.call(*ret) })
    end
  end

  def dynamicwind(before, thunk, after)
    mark = __top
    __switch(Stack[[before, nil], [nil, after], mark])
    thunk.call ensure __switch(mark)
  end

  def __top
    Thread.current[:dynamicwind_stack] ||= Stack.new
  end

  def __top=(x)
    Thread.current[:dynamicwind_stack] = x
  end

  def __switch(mark)
    return if __top.equal?(mark)
    __switch(mark.next)
    fst, snd = mark.fst, mark.snd
    fst.first.call if fst.first
    __top.fst = snd
    __top.snd = fst
    __top.next = mark
    self.__top = mark
    __top.fst = nil
    __top.snd = nil
    __top.next = nil
    fst.last.call if fst.last
  end
end

include DynamicWind
