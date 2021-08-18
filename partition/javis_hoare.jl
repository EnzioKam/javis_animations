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

function hoare(gif::Bool=true)
    num_frames = 450
    array_values = [33; 25; 1; 34; 70; 3; 31; 45; 18; 92; 50; 84; 63; 88; 21; 75]
    array_values_static = [33; 25; 1; 34; 70; 3; 31; 45; 18; 92; 50; 84; 63; 88; 21; 75]

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

        if i == 8
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
            make_arrow(Point(375, 150), Point(375, 100)),
    )
    end_text = Object((args...) -> make_text(20, "j", pos(end_arrow) + Point(0, 25)))
    act!(end_arrow, Action(1:15, sineio(), appear(:fade)))
    act!(end_text, Action(1:15, sineio(), appear(:draw_text)))

    t0 = Object((args...; color="grey", align=:left) ->
        make_text(20, "while i < j", Point(-150, -400), color, align))
    t1 = Object((args...; color="grey", align=:left) ->
        make_text(20, "    while A[i] < pivot and i <= hi", Point(-150, -375), color, align))
    t2 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        i = i + 1", Point(-150, -350), color, align))
    t3 = Object((args...; color="grey", align=:left) ->
        make_text(20, "    while A[j] > pivot and j >= lo", Point(-150, -325), color, align))
    t4 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        j = j - 1", Point(-150, -300), color, align))
    t5 = Object((args...; color="grey", align=:left) ->
        make_text(20, "    if i < j", Point(-150, -275), color, align))
    t6 = Object((args...; color="grey", align=:left) ->
        make_text(20, "        swap A[i] and A[j]", Point(-150, -250), color, align))

    lo = 1
    hi = 16
    pivot = array_values[floor((hi + lo) ÷ 2)]
    i = lo
    j = hi

    fno = 30
    while i < j
        sf = [0, 0]
        while array_values[i] < pivot && i <= hi
            i += 1
            act!(start_arrow, Action(fno:fno+15, sineio(), anim_translate(50, 0)))
            act!(t1, Action(fno:fno+15, change(:color, "black")))
            act!(t2, Action(fno:fno+15, change(:color, "black")))
            fno += 15
        end
        sf[1] = fno
        while array_values[j] > pivot && j >= lo
            j -= 1
            act!(end_arrow, Action(fno:fno+15, sineio(), anim_translate(-50, 0)))
            fno += 15
            act!(t3, Action(fno:fno+15, change(:color, "black")))
            act!(t4, Action(fno:fno+15, change(:color, "black")))
        end
        sf[2] = fno
        if i < j
            swap_values!(rectangles, array_values, fno, i, j)
            act!(t5, Action(fno:fno+45, change(:color, "black")))
            act!(t6, Action(fno:fno+45, change(:color, "black")))
            fno += 45
        end
        act!(t1, Action(sf[1]:fno+5, change(:color, "grey")))
        act!(t2, Action(sf[1]:fno+5, change(:color, "grey")))
        act!(t3, Action(sf[2]:fno+5, change(:color, "grey")))
        act!(t4, Action(sf[2]:fno+5, change(:color, "grey")))
        act!(t5, Action(fno:fno+5, change(:color, "grey")))
        act!(t6, Action(fno:fno+5, change(:color, "grey")))
        fno += 5
    end
    act!(t0, Action(30:fno, change(:color, "black")))
    act!(t0, Action(fno:360, change(:color, "grey")))

    for j in 1:16
        if  j <= i - 1
            act!(rectangles[j], Action(380:num_frames-15, change(:color, "green")))
        elseif j >= i + 1
            act!(rectangles[j], Action(380:num_frames-15, change(:color, "blue")))
        end
    end

    render(
        video;
        pathname = if gif "hoare.gif" else "hoare.mp4" end,
        framerate = 30
    )
    return fno
end

hoare()
hoare(false)
