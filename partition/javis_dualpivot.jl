using Javis, Animations, Colors

function ground(args...)
    background("white")
    sethue("black")
end

function rectangle(point, w, h, action, color="black")
    sethue(color)
    rect(point, w, h, action)
    return point
end

function make_text(ftsize, str, pos=O, color="black", align=:center)
    sethue(color)
    fontsize(ftsize)
    text(str, pos, halign=align)
    return pos
end

function make_arrow(startpoint, endpoint)
    arrow(startpoint, endpoint)
    return startpoint
end

function swap_values!(rectangles, array_values, fno, i, j)
    a = rectangles[i]
    b = rectangles[j]

    act!(a, Action(fno:fno+15, sineio(), disappear(:fade)))
    act!(a, Action(fno+15:fno+30, sineio(), anim_translate((j - i) * 50, 0)))
    act!(a, Action(fno+30:fno+45, sineio(), appear(:fade)))

    act!(b, Action(fno:fno+15, sineio(), disappear(:fade)))
    act!(b, Action(fno+15:fno+30, sineio(), anim_translate((j - i) * -50, 0)))
    act!(b, Action(fno+30:fno+45, sineio(), appear(:fade)))

    rectangles[i], rectangles[j] = rectangles[j], rectangles[i]
    array_values[i], array_values[j] = array_values[j], array_values[i]
end

function dualpivot(gif::Bool=true)
    num_frames = 600
    array_values = [33; 25; 45; 34; 70; 3; 31; 45; 18; 92; 50; 45; 63; 88; 45; 75]
    array_values_static = [33; 25; 45; 34; 70; 3; 31; 45; 18; 92; 50; 45; 63; 88; 45; 75]

    video = Video(1000, 1000)
    Background(1:num_frames, ground)

    rectangles = Object[]
    indices = Object[]
    values = Object[]

    for i in 1:16
        x_loc = -400 + (i - 1) * 50
        my_rect = Object((args...; color="black") -> rectangle(Point(x_loc, 0), 50, 50, :stroke, color))
        push!(rectangles, my_rect)

        my_index =  Object((args...) -> make_text(20, "$i", Point(x_loc, 0) + Point(25, 75), "grey"))
        act!(my_index, Action(1:15, sineio(), appear(:draw_text)))
        push!(indices, my_index)

        if i == 1
            my_value = Object((args...) ->
                make_text(20, "$(array_values_static[i])", pos(my_rect) + Point(25, 25), "red"))
        elseif i == 16
            my_value = Object((args...) ->
                make_text(20, "$(array_values_static[i])", pos(my_rect) + Point(25, 25), "purple"))
        else
            my_value = Object((args...) ->
                make_text(20, "$(array_values_static[i])", pos(my_rect) + Point(25, 25)))
        end
        
        act!(my_value, Action(1:15, sineio(), appear(:draw_text)))
        push!(values, my_value)
    end

    start_arrow = Object(
        (args...) ->
            make_arrow(Point(-325, -75), Point(-325, -25)),
    )
    start_text = Object((args...) -> make_text(20, "i", pos(start_arrow) + Point(0, -25)))
    act!(start_arrow, Action(1:15, sineio(), appear(:fade)))
    act!(start_text, Action(1:15, sineio(), appear(:draw_text)))

    middle_arrow = Object(
        (args...) ->
            make_arrow(Point(-325, 150), Point(-325, 100)),
    )
    middle_text = Object((args...) -> make_text(20, "j", pos(middle_arrow) + Point(0, 25)))
    act!(middle_arrow, Action(1:15, sineio(), appear(:fade)))
    act!(middle_text, Action(1:15, sineio(), appear(:draw_text)))

    end_arrow = Object(
        (args...) ->
            make_arrow(Point(325, 150), Point(325, 100)),
    )
    end_text = Object((args...) -> make_text(20, "k", pos(end_arrow) + Point(0, 25)))
    act!(end_arrow, Action(1:15, sineio(), appear(:fade)))
    act!(end_text, Action(1:15, sineio(), appear(:draw_text)))

    t0 = Object((args...; color="grey", align=:left) ->
        make_text(20, "while j <= k", Point(-150, -400), color, align))
    t1 = Object((args...; color="grey", align=:left) ->
        make_text(20, "    if A[j] < p", Point(-150, -375), color, align))
    t2 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        swap A[i] and A[j]", Point(-150, -350), color, align))
    t3 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        i + i + 1, j = j + 1", Point(-150, -325), color, align))
    t4 = Object((args...; color="grey", align=:left) ->
        make_text(20, "    elseif A[j] > q", Point(-150, -300), color, align))
    t5 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        swap A[j] and A[k]", Point(-150, -275), color, align))
    t6 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        k = k - 1", Point(-150, -250), color, align))
    t7 = Object((args...; color="grey", align=:left) ->
        make_text(20, "    else", Point(-150, -225), color, align))
    t8 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        j = j + 1", Point(-150, -200), color, align))
    t9 = Object((args...; color="grey", align=:left) ->
        make_text(20, "i = i - 1, k = k + 1", Point(-150, -175), color, align))
    t10 = Object((args...; color="grey", align=:left) ->
        make_text(20, "swap A[lo] and A[i], swap A[hi] and A[k]", Point(-150, -150), color, align))

    lo = 1
    hi = 16
    p = array_values[lo]
    q = array_values[hi]
    i = lo + 1
    j = lo + 1
    k = hi - 1

    fno = 30
    while j <= k
        if array_values[j] < p
            if i != j
                swap_values!(rectangles, array_values, fno, i, j)
                act!(t1, Action(fno:fno+45, change(:color, "black")))
                act!(t2, Action(fno:fno+45, change(:color, "black")))
                act!(t3, Action(fno:fno+45, change(:color, "black")))
                act!(t1, Action(fno+45:540, change(:color, "grey")))
                act!(t2, Action(fno+45:540, change(:color, "grey")))
                act!(t3, Action(fno+45:540, change(:color, "grey")))
                fno += 45
            else
                act!(t1, Action(fno:fno+15, change(:color, "black")))
                act!(t2, Action(fno:fno+15, change(:color, "black")))
                act!(t3, Action(fno:fno+15, change(:color, "black")))
                act!(t1, Action(fno+15:540, change(:color, "grey")))
                act!(t2, Action(fno+15:540, change(:color, "grey")))
                act!(t3, Action(fno+15:540, change(:color, "grey")))
                fno += 15
            end
            
            i += 1
            j += 1
            act!(start_arrow, Action(fno:fno+15, sineio(), anim_translate(50, 0)))
            act!(middle_arrow, Action(fno:fno+15, sineio(), anim_translate(50, 0)))
            fno += 15
        elseif array_values[j] > q
            if j != k
                swap_values!(rectangles, array_values, fno, j, k)
                act!(t4, Action(fno:fno+45, change(:color, "black")))
                act!(t5, Action(fno:fno+45, change(:color, "black")))
                act!(t6, Action(fno:fno+45, change(:color, "black")))
                act!(t4, Action(fno+45:540, change(:color, "grey")))
                act!(t5, Action(fno+45:540, change(:color, "grey")))
                act!(t6, Action(fno+45:540, change(:color, "grey")))
                fno += 45
            else
                act!(t4, Action(fno:fno+15, change(:color, "black")))
                act!(t5, Action(fno:fno+15, change(:color, "black")))
                act!(t6, Action(fno:fno+15, change(:color, "black")))
                act!(t4, Action(fno+15:540, change(:color, "grey")))
                act!(t5, Action(fno+15:540, change(:color, "grey")))
                act!(t6, Action(fno+15:540, change(:color, "grey")))
                fno += 15
            end

            k -= 1
            act!(end_arrow, Action(fno:fno+15, sineio(), anim_translate(-50, 0)))
            fno += 15
        else
            j += 1
            act!(middle_arrow, Action(fno:fno+15, sineio(), anim_translate(50, 0)))
            act!(t7, Action(fno:fno+15, change(:color, "black")))
            act!(t8, Action(fno:fno+15, change(:color, "black")))
            act!(t7, Action(fno+15:540, change(:color, "grey")))
            act!(t8, Action(fno+15:540, change(:color, "grey")))

            fno += 15
        end
    end
    act!(t0, Action(30:fno, change(:color, "black")))
    act!(t0, Action(fno:540, change(:color, "grey")))

    i -= 1
    k += 1
    act!(t9, Action(fno:fno+115, change(:color, "black")))
    act!(t10, Action(fno:fno+115, change(:color, "black")))
    act!(start_arrow, Action(fno:fno+15, sineio(), anim_translate(-50, 0)))
    act!(end_arrow, Action(fno:fno+15, sineio(), anim_translate(50, 0)))
    fno += 15
    swap_values!(rectangles, array_values, fno, lo, i)
    fno += 45
    swap_values!(rectangles, array_values, fno, hi, k)
    fno += 45
    act!(t9, Action(fno:num_frames-15, change(:color, "grey")))
    act!(t10, Action(fno:num_frames-15, change(:color, "grey")))

    for j in 1:16
        if  j < i
            act!(rectangles[j], Action(540:num_frames-15, change(:color, "green")))
        elseif j > k
            act!(rectangles[j], Action(540:num_frames-15, change(:color, "blue")))
        elseif j > i && j < k
            println(j)
            act!(rectangles[j], Action(540:num_frames-15, change(:color, "red")))
        end
    end

    render(
        video;
        pathname = if gif "dualpivot.gif" else "dualpivot.mp4" end,
        framerate = 30
    )
    return fno
end

dualpivot()
dualpivot(false)
