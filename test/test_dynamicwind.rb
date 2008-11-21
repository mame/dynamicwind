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

  def test_jump_from_before_to_before
    ary = []
    ctn = nil
    i = 0
    while i <= 1
      dynamicwind(
        proc do
          ary << :before1
          ctn.call if ctn
          ary << :before2
          callcc {|c| ctn = c }
          ary << :before3
        end,
        proc { ary << :thunk },
        proc { ary << :after }
      )
      ary << :end
      i += 1
    end
    assert_equal([:before1, :before2, :before3, :thunk, :after, :end, :before1, :before3, :thunk, :after, :end], ary)
  end

  def test_jump_from_before_to_thunk
    ary = []
    ctn = nil
    flag = true
    i = 0
    while i <= 1
      dynamicwind(
        proc do
          ary << :before1
          (flag = false; ctn.call) if ctn && flag
          ary << :before2
        end,
        proc do
          ary << :thunk1
          callcc {|c| ctn = c }
          ary << :thunk2
        end,
        proc { ary << :after }
      )
      ary << :end
      i += 1
    end
    assert_equal([:before1, :before2, :thunk1, :thunk2, :after, :end, :before1, :before1, :before2, :thunk2, :after, :end], ary)
  end

  def test_jump_from_before_to_after
    ary = []
    ctn = nil
    i = 0
    while i <= 1
      dynamicwind(
        proc do
          ary << :before1
          ctn.call if ctn
          ary << :before2
        end,
        proc { ary << :thunk },
        proc do
          ary << :after1
          callcc {|c| ctn = c }
          ary << :after2
        end
      )
      ary << :end
      i += 1
    end
    assert_equal([:before1, :before2, :thunk, :after1, :after2, :end, :before1, :after2, :end], ary)
  end

  def test_jump_from_thunk_to_before
    ary = []
    ctn = nil
    flag = true
    dynamicwind(
      proc do
        ary << :before1
        callcc {|c| ctn = c }
        ary << :before2
      end,
      proc do
        ary << :thunk1
        (flag = false; ctn.call) if flag
        ary << :thunk2
      end,
      proc { ary << :after }
    )
    assert_equal([:before1, :before2, :thunk1, :after, :before2, :thunk1, :thunk2, :after], ary)
  end

  def test_jump_from_thunk_to_before_2
    ary = []
    ctn = nil
    flag = true
    i = 0
    while i <= 1
      dynamicwind(
        proc do
          ary << :before1
          callcc {|c| ctn = c } if i == 0
          ary << :before2
        end,
        proc do
          ary << :thunk1
          (flag = false; ctn.call) if i == 1 && flag
          ary << :thunk2
        end,
        proc { ary << :after }
      )
      ary << :end
      i += 1
    end
    assert_equal([:before1, :before2, :thunk1, :thunk2, :after, :end, :before1, :before2, :thunk1, :after, :before2, :thunk1, :thunk2, :after, :end], ary)
  end

  def test_jump_from_thunk_to_thunk
    ary = []
    ctn = nil
    flag = true
    i = 0
    while i <= 1
      dynamicwind(
        proc do
          ary << :before1
          callcc {|c| ctn = c } if i == 0
          ary << :before2
        end,
        proc do
          ary << :thunk1
          (flag = false; ctn.call) if i == 1 && flag
          ary << :thunk2
        end,
        proc { ary << :after }
      )
      ary << :end
      i += 1
    end
    assert_equal([:before1, :before2, :thunk1, :thunk2, :after, :end, :before1, :before2, :thunk1, :after, :before2, :thunk1, :thunk2, :after, :end], ary)
  end

  def test_jump_from_thunk_to_after
    ary = []
    ctn = nil
    i = 0
    while i <= 1
      dynamicwind(
        proc { ary << :before },
        proc do
          ary << :thunk1
          ctn.call if ctn
          ary << :thunk2
        end,
        proc do
          ary << :after1
          callcc {|c| ctn = c }
          ary << :after2
        end
      )
      ary << :end
      i += 1
    end
    assert_equal([:before, :thunk1, :thunk2, :after1, :after2, :end, :before, :thunk1, :after1, :after2, :after2, :end], ary)
  end

  def test_jump_from_after_to_before
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

  def test_jump_from_after_to_before_2
    ary = []
    ctn = nil
    flag = true
    i = 0
    while i <= 1
      dynamicwind(
        proc do
          ary << :before1
          callcc {|c| ctn = c } if i == 0
          ary << :before2
        end,
        proc { ary << :thunk },
        proc do
          ary << :after1
          (flag = false; ctn.call) if i == 1 && flag
          ary << :after2
        end
      )
      ary << :end
      i += 1
    end
    assert_equal([:before1, :before2, :thunk, :after1, :after2, :end, :before1, :before2, :thunk, :after1, :before2, :thunk, :after1, :after2, :end], ary)
  end

  def test_jump_from_after_to_thunk
    ary = []
    ctn = nil
    flag = true
    dynamicwind(
      proc { ary << :before },
      proc do
        ary << :thunk1
        callcc {|c| ctn = c }
        ary << :thunk2
      end,
      proc do
        ary << :after1
        (flag = false; ctn.call) if flag
        ary << :after2
      end
    )
    assert_equal([:before, :thunk1, :thunk2, :after1, :before, :thunk2, :after1, :after2], ary)
  end

  def test_jump_from_after_to_thunk_2
    ary = []
    ctn = nil
    flag = true
    i = 0
    while i <= 1
      dynamicwind(
        proc { ary << :before },
        proc do
          ary << :thunk1
          callcc {|c| ctn = c } if i == 0
          ary << :thunk2
        end,
        proc do
          ary << :after1
          (flag = false; ctn.call) if i == 1 && flag
          ary << :after2
        end
      )
      ary << :end
      i += 1
    end
    assert_equal([:before, :thunk1, :thunk2, :after1, :after2, :end, :before, :thunk1, :thunk2, :after1, :before, :thunk2, :after1, :after2, :end], ary)
  end

  def test_jump_from_after_to_after
    ary = []
    ctn = nil
    i = 0
    while i <= 1
      dynamicwind(
        proc { ary << :before },
        proc { ary << :thunk },
        proc do
          ary << :after1
          ctn.call if ctn
          ary << :after2
          callcc {|c| ctn = c }
          ary << :after3
        end
      )
      ary << :end
      i += 1
    end
    assert_equal([:before, :thunk, :after1, :after2, :after3, :end, :before, :thunk, :after1, :after3, :end], ary)
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

  def test_raise_in_before
    ary = []
    ctn = nil
    flag = true
    begin
      dynamicwind(
        proc do
          ary << :before
          raise if ctn
        end,
        proc do
          ary << :thunk1
          callcc {|c| ctn = c }
          ary << :thunk2
        end,
        proc { ary << :after }
      )
      ary << :normal
    rescue
      ary << :exception
    end
    ary << :end
    assert_nothing_raised { flag = false; ctn.call } if flag
    assert_equal([:before, :thunk1, :thunk2, :after, :normal, :end, :before, :exception, :end], ary)
  end

  def test_raise_in_after
    ary = []
    ctn = nil
    assert_nothing_raised do
      dynamicwind(
        proc { ary << :before1 },
        proc do
          ary << :thunk1
          callcc {|c| ctn = c }
          ary << :thunk2
        end,
        proc { ary << :after1 }
      )
    end
    ary << :between
    begin
      dynamicwind(
        proc { ary << :before2 },
        proc do
          ary << :thunk3
          assert_nothing_raised { ctn.call }
        end,
        proc { ary << :after2; raise }
      )
    rescue
      ary << :exception
    end
    ary << :end
    assert_equal([:before1, :thunk1, :thunk2, :after1, :between, :before2, :thunk3, :after2, :exception, :end], ary)
  end

  def test_callcc_in_thunk
    ary = []
    dynamicwind(
      proc { ary << :before },
      proc do
        callcc do |c|
          ary << :thunk1
          c.call
          ary << :thunk2
        end
      end,
      proc { ary << :after }
    )
    assert_equal([:before, :thunk1, :after], ary)
  end
end
