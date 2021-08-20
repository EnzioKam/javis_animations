using Javis, Animations, Colors

function ground(args...)
    background("white")
    sethue("black")
end

function make_rectangle(point, w, h, action=:stroke, color="black")
    sethue(color)
    rect(point, w, h, action)
    return point
end

function make_circle(x, y, r, action=:stroke, color="black")
    sethue(color)
    circle(x, y, r, action)
    return Point(x, y)
end

function make_text(ftsize, str, pos=O, color="black", align=:center)
    sethue(color)
    fontsize(ftsize)
    text(str, pos, halign=align)
    return pos
end

function swap_values!(rectangles, array_values, heap, heap_values, hpositions, fno, i, j)
    a = rectangles[i]
    b = rectangles[j]
    c = heap[i]
    d = heap[j]
    cpos = hpositions[i]
    dpos = hpositions[j]

    act!(a, Action(fno+1:fno+15, sineio(), disappear(:fade)))
    act!(a, Action(fno+16:fno+30, sineio(), anim_translate((j - i) * 50, 0)))
    act!(a, Action(fno+31:fno+45, sineio(), appear(:fade)))

    act!(b, Action(fno+1:fno+15, sineio(), disappear(:fade)))
    act!(b, Action(fno+16:fno+30, sineio(), anim_translate((j - i) * -50, 0)))
    act!(b, Action(fno+31:fno+45, sineio(), appear(:fade)))

    act!(c, Action(fno+1:fno+15, sineio(), disappear(:fade)))
    act!(c, Action(fno+16:fno+30, sineio(), anim_translate(dpos - cpos)))
    act!(c, Action(fno+31:fno+45, sineio(), appear(:fade)))

    act!(d, Action(fno+1:fno+15, sineio(), disappear(:fade)))
    act!(d, Action(fno+16:fno+30, sineio(), anim_translate(cpos - dpos)))
    act!(d, Action(fno+31:fno+45, sineio(), appear(:fade)))

    rectangles[i], rectangles[j] = rectangles[j], rectangles[i]
    array_values[i], array_values[j] = array_values[j], array_values[i]
    heap[i], heap[j] = heap[j], heap[i]
    heap_values[i], heap_values[j] = heap_values[j], heap_values[i]
    return fno + 45
end

function get_direction_offset(a, b, r)
    xdiff = b.x - a.x
    ydiff = b.y - a.y

    sr = sqrt(2) / 2 * r
    offsets = [
        (sr, sr), (-sr, -sr), (sr, -sr), (-sr, sr), (0, r), (0, -r), (r, 0), (-r, 0)
    ]

    if ydiff > 0 && xdiff > 0 # right-down diagonal
        return offsets[1]
    elseif ydiff < 0 && xdiff < 0 # left-up diagonal
        return offsets[2]
    elseif ydiff < 0 && xdiff > 0 # right-up diagonal
        return offsets[3]
    elseif ydiff > 0 && xdiff < 0 # left-down diagonal
        return offsets[4]
    elseif ydiff > 0 # down
        return offsets[5]
    elseif ydiff < 0 # up
        return offsets[6]
    elseif xdiff > 0 # right
        return offsets[7]
    else # xdiff < 0 # left
        return offsets[8]
    end
end

function draw_line(startpoint, endpoint, radius)
    sethue("black")
    x, y = get_direction_offset(startpoint, endpoint, radius)
    line(startpoint + Point(x, y), endpoint + Point(-x, -y), :stroke)
    return startpoint
end

function make_heap(values)
    xpos = 0
    ypos = -200
    r = 30
    xoffset = 800
    yoffset = 150

    n = length(values)
    heap = Object[]
    heap_values = Object[]
    hpositions = Point[]

    row_max = 1
    index = 1
    xstart = xpos
    while index <= n
        l = index + row_max - 1
        while index <= min(l, n)
            node = Object(JCircle(xpos, ypos, r; color="black", action=:stroke))
            push!(heap, node)
            push!(hpositions, Point(xpos, ypos))
            xpos += xoffset
            index += 1
        end
        xoffset /= 2
        xstart -= xoffset / 2
        xpos = xstart
        ypos += yoffset
        row_max <<= 1 # double the value
    end

    c = 1
    for i in 1:n
        vtext = Object((args...) -> make_text(20, "$(values[i])", pos(heap[i])))
        push!(heap_values, vtext)

        if i << 1 <= n
            Object((args...) -> draw_line(hpositions[i], hpositions[i << 1], r))
        end
        if i << 1 + 1 <= n
            Object((args...) -> draw_line(hpositions[i], hpositions[i << 1 + 1], r))
        end
    end
    return (heap, heap_values, hpositions)
end

function heapify(gif::Bool=true)
    nframes = 430
    array_values = [5; 25; 1; 34; 70; 3; 31; 45; 18; 92]
    array_values_static = [5; 25; 1; 34; 70; 3; 31; 45; 18; 92]
    n = length(array_values_static)
    xpos = -250
    ypos = -400
    bsize = 50

    video = Video(1000, 1000)
    Background(1:nframes, ground)

    rectangles = Object[]
    indices = Object[]
    values = Object[]
    
    for i in 1:n
        x_loc = xpos + (i - 1) * bsize
        my_rect = Object((args...; color="black") -> make_rectangle(Point(x_loc, ypos), bsize, bsize, :stroke, color))
        push!(rectangles, my_rect)

        my_index =  Object((args...) -> 
            make_text(20, "$i", Point(x_loc, ypos) + Point(bsize / 2, bsize / 2 * 3), "grey"))
        push!(indices, my_index)

        my_value = Object((args...) -> make_text(20, "$(array_values_static[i])", pos(my_rect) + Point(25, 25)))
        push!(values, my_value)
    end

    heap, heap_values, hpositions = make_heap(array_values)

    pointer = Object((args...) -> arrow(hpositions[n >> 1] + Point(0, -80), hpositions[n >> 1] + Point(0, -30)))

    fno = 10
    for i in n:-1:1
        if 1 <= i <= n >> 1 - 1
            println(i)
            diff = hpositions[i] - hpositions[i + 1]
            act!(pointer, Action(fno+1:fno+15, sineio(), anim_translate(diff)))
        end
        fno += 5
        while true
            l = i << 1
            r = i << 1 + 1
            best = i
            if l <= n && array_values[l] > array_values[i]
                best = l
            end
            if r <= n && array_values[r] > array_values[best]
                best = r
            end
            if best == i
                break
            end
            fno = swap_values!(rectangles, array_values, heap, heap_values, hpositions, fno, i, best)
            i = best
        end
    end

    render(
        video;
        pathname = if gif "heapify.gif" else "heapify.mp4" end,
        framerate = 30
    )
    return fno
end

heapify()
heapify(false)
