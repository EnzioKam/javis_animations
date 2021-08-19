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

function heapify(gif::Bool=true)
    num_frames = 50
    array_values = [33; 25; 1; 34; 70; 3; 31; 45; 18; 92]
    array_values_static = [33; 25; 1; 34; 70; 3; 31; 45; 18; 92]
    n = length(array_values_static)
    xpos = -250
    ypos = -450
    bsize = 50

    video = Video(1000, 1000)
    Background(1:num_frames, ground)

    rectangles = Object[]
    indices = Object[]
    values = Object[]

    
    for i in 1:n
        x_loc = xpos + (i - 1) * bsize
        my_rect = Object((args...; color="black") -> rectangle(Point(x_loc, ypos), bsize, bsize, :stroke, color))
        push!(rectangles, my_rect)

        my_index =  Object((args...) -> 
            make_text(20, "$i", Point(x_loc, ypos) + Point(bsize / 2, bsize / 2 * 3), "grey"))
        push!(indices, my_index)

        my_value = Object((args...) -> make_text(20, "$(array_values_static[i])", pos(my_rect) + Point(25, 25)))
        push!(values, my_value)
    end

    # start_arrow = Object(
    #     (args...) ->
    #         make_arrow(Point(xpos + bsize / 2, ypos - bsize / 2 * 3), Point(xpos + bsize / 2, ypos - bsize / 2)),
    # )
    # start_text = Object((args...) -> make_text(20, "i", pos(start_arrow) + Point(0, -25)))

    render(
        video;
        pathname = if gif "heapify.gif" else "heapify.mp4" end,
        framerate = 30
    )
    # return fno
end

heapify()
# heapify(false)
