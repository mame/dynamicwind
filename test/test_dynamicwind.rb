require "dynamicwind"
require "test/unit"

class TestDynamicWind < Test::Unit::TestCase
  def test_leave
    ary = []
    callcc do |c|
      dynamicwind(
        proc { ary << :before },
        proc { ary << :thunk; c.call },
        proc { ary << :after }
      )
    end
    assert_equal([:before, :thunk, :after], ary)
  end

  def test_enter
    ary = []
    ctn = nil
    flag = true
    dynamicwind(
      proc { ary << :before },
      proc { callcc {|c| ctn = c }; ary << :thunk },
      proc { ary << :after }
    )
    (flag = false; ctn.call) if flag
    assert_equal([:before, :thunk, :after] * 2, ary)
  end

  def test_leave_enter
    ary = []
    c2 = nil
    flag = true
    callcc do |c1|
      dynamicwind(
        proc { ary << :before },
        proc do
          ary << :thunk1
          callcc {|c| c2 = c }
          ary << :thunk2
          c1.call
          ary << :thunk3
        end,
        proc { ary << :after }
      )
    end
    ary << :end
    (flag = false; c2.call) if flag
    assert_equal([:before, :thunk1, :thunk2, :after, :end, :before, :thunk2, :after, :end], ary)
  end

  def test_leave_enter_2
    ary = []
    c2 = nil
    flag = true
    callcc do |c1|
      dynamicwind(
        proc { ary << :before },
        proc do
          ary << :thunk1
          callcc do |c|
            c2 = c
            ary << :thunk2
            c1.call
          end
          ary << :thunk3
        end,
        proc { ary << :after }
      )
    end
    ary << :end
    (flag = false; c2.call) if flag
    assert_equal([:before, :thunk1, :thunk2, :after, :end, :before, :thunk3, :after, :end], ary)
  end

  def test_callcc_in_before
    ary = []
    ctn = nil
    flag = true
    dynamicwind(
      proc do
        ary << :before1
        callcc {|c| ctn = c }
        ary << :before2
      end,
      proc { ary << :thunk },
      proc do
        ary << :after1
        (flag = false; ctn.call) if flag
        ary << :after2
      end
    )
    assert_equal([:before1, :before2, :thunk, :after1, :before2, :thunk, :after1, :after2], ary)
  end

  def test_raise
    ary = []
    assert_raise(RuntimeError) do
      dynamicwind(
        proc { ary << :before; raise },
        proc { ary << :thunk },
        proc { ary << :after }
      )
    end
    assert_equal([:before], ary)

    ary = []
    assert_raise(RuntimeError) do
      dynamicwind(
        proc { ary << :before },
        proc { ary << :thunk; raise },
        proc { ary << :after }
      )
    end
    assert_equal([:before, :thunk, :after], ary)

    ary = []
    assert_raise(RuntimeError) do
      dynamicwind(
        proc { ary << :before },
        proc { ary << :thunk },
        proc { ary << :after; raise }
      )
    end
    assert_equal([:before, :thunk, :after], ary)
  end

  def test_throw
    ary = []
    assert_throws(:foo) do
      dynamicwind(
        proc { ary << :before; throw :foo },
        proc { ary << :thunk },
        proc { ary << :after }
      )
    end
    assert_equal([:before], ary)

    ary = []
    assert_throws(:foo) do
      dynamicwind(
        proc { ary << :before },
        proc { ary << :thunk; throw :foo },
        proc { ary << :after }
      )
    end
    assert_equal([:before, :thunk, :after], ary)

    ary = []
    assert_throws(:foo) do
      dynamicwind(
        proc { ary << :before },
        proc { ary << :thunk },
        proc { ary << :after; throw :foo }
      )
    end
    assert_equal([:before, :thunk, :after], ary)
  end

  def test_double_wind
    ary = []
    c2 = nil
    flag = true
    callcc do |c1|
      dynamicwind(
        proc { ary << :before1 },
        proc do
          dynamicwind(
            proc { ary << :before2 },
            proc do
              ary << :thunk1
              callcc do |c|
                c2 = c
                c1.call
              end
              ary << :thunk2
            end,
            proc { ary << :after2 }
          )
        end,
        proc { ary << :after1 }
      )
    end
    ary << :end
    (flag = false; c2.call) if flag
    assert_equal([:before1, :before2, :thunk1, :after2, :after1, :end, :before1, :before2, :thunk2, :after2, :after1, :end], ary)
  end
end
