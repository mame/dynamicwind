begin
  require "continuation"
rescue LoadError
end

module DynamicWind
  VERSION = '1.0.1'

  Stack = Struct.new(:fst, :snd, :next)

  alias __callcc_orig callcc

  def callcc
    mark = __top
    __callcc_orig do |ctn|
      yield(proc {|*ret| __switch(mark); ctn.call(*ret) })
    end
  end

  def dynamicwind(before, thunk, after)
    before_ = after_ = nil
    if ctn_before = __callcc_orig {|c| before_ = c; false }
      before.call
      ctn_before.call
    end
    if ctn_after = __callcc_orig {|c| after_ = c; false }
      after.call
      ctn_after.call
    end
    mark = __top
    __switch(Stack[[before_, nil], [nil, after_], mark])
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
    __callcc_orig {|c| fst.first.call(c) } if fst.first
    __top.fst = snd
    __top.snd = fst
    __top.next = mark
    self.__top = mark
    __top.fst = nil
    __top.snd = nil
    __top.next = nil
    __callcc_orig {|c| fst.last.call(c) } if fst.last
  end
end

include DynamicWind
