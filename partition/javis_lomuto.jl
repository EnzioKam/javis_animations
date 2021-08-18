using Base: array_subpadding
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

function lomuto(gif::Bool=true)
    num_frames = 600
    array_values = [33; 25; 1; 34; 70; 3; 31; 75; 18; 92; 50; 84; 63; 88; 21; 45]
    array_values_static = [33; 25; 1; 34; 70; 3; 31; 75; 18; 92; 50; 84; 63; 88; 21; 45]

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

        if i == 16
            my_value = Object(16:num_frames, (args...) ->
                make_text(20, "$(array_values_static[i])", pos(my_rect) + Point(25, 25), "red"))
        else
            my_value = Object(16:num_frames, (args...) ->
                make_text(20, "$(array_values_static[i])", pos(my_rect) + Point(25, 25)))
        end
        
        act!(my_value, Action(1:15, sineio(), appear(:draw_text)))
        push!(values, my_value)
    end

    start_arrow = Object(
        (args...) ->
            make_arrow(Point(-375, -75), Point(-375, -25)),
    )
    start_text = Object((args...) -> make_text(20, "i", pos(start_arrow) + Point(0, -25)))
    act!(start_arrow, Action(1:15, sineio(), appear(:fade)))
    act!(start_text, Action(1:15, sineio(), appear(:draw_text)))

    end_arrow = Object(
        (args...) ->
            make_arrow(Point(-375, 150), Point(-375, 100)),
    )
    end_text = Object((args...) -> make_text(20, "j", pos(end_arrow) + Point(0, 25)))
    act!(end_arrow, Action(1:15, sineio(), appear(:fade)))
    act!(end_text, Action(1:15, sineio(), appear(:draw_text)))

    t1 = Object((args...; color="grey", align=:left) ->
        make_text(20, "for j = lo to hi - 1", Point(-150, -400), color, align))
    t2 = Object((args...; color="grey", align=:left) ->
        make_text(20, "    if A[j] < pivot", Point(-150, -375), color, align))
    t3 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        swap A[i] and A[j]", Point(-150, -350), color, align))
    t4 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        i += 1", Point(-150, -325), color, align))
    t5 = Object((args...; color="grey", align=:left) ->
        make_text(20, "swap A[i] and A[hi]", Point(-150, -300), color, align))

    lo = 1
    hi = 16
    pivot = array_values[hi]
    i = lo

    fno = 30
    for j in lo:hi-1
        if array_values[j] < pivot
            if i != j
                swap_values!(rectangles, array_values, fno, i, j)
                act!(t2, Action(fno:fno+45, change(:color, "black")))
                act!(t3, Action(fno:fno+45, change(:color, "black")))
                act!(t4, Action(fno:fno+45, change(:color, "black")))
                fno += 45
            else
                act!(t2, Action(fno:fno+15, change(:color, "black")))
                act!(t3, Action(fno:fno+15, change(:color, "black")))
                act!(t4, Action(fno:fno+15, change(:color, "black")))
                fno += 15
            end
            i += 1
            act!(start_arrow, Action(fno:fno+15, sineio(), anim_translate(50, 0)))
        else
            act!(t2, Action(fno:fno+15, change(:color, "grey")))
            act!(t3, Action(fno:fno+15, change(:color, "grey")))
            act!(t4, Action(fno:fno+15, change(:color, "grey")))
        end
        act!(end_arrow, Action(fno:fno+15, sineio(), anim_translate(50, 0)))
        fno += 15
    end
    act!(t1, Action(30:fno, change(:color, "black")))
    act!(t1, Action(fno:540, change(:color, "grey")))
    act!(t2, Action(fno:540, change(:color, "grey")))
    act!(t3, Action(fno:540, change(:color, "grey")))
    act!(t4, Action(fno:540, change(:color, "grey")))

    swap_values!(rectangles, array_values, fno, i, hi)
    act!(t5, Action(fno:fno+45, change(:color, "black")))
    act!(t5, Action(fno+45:540, change(:color, "grey")))
    fno += 45

    for j in 1:16
        if  j <= i - 1
            act!(rectangles[j], Action(560:num_frames-15, change(:color, "green")))
        elseif j >= i + 1
            act!(rectangles[j], Action(560:num_frames-15, change(:color, "blue")))
        end
    end

    render(
        video;
        pathname = if gif "lomuto.gif" else "lomuto.mp4" end,
        framerate = 30
    )
    return fno
end

lomuto()
lomuto(false)
