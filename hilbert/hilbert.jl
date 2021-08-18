using Javis, Colors

function ground(args...)
    background("black")
    sethue("white")
end

# From cormullion/hilbert-animation.jl at: https://gist.github.com/cormullion/40cca8cc3ad7a315fe2f943dbe832797
function hilbert_helper(
    pointslist::Array{Point,1},
    start::Point,
    unitx::Point,
    unity::Point,
    depth,
)
    if depth <= 0
        push!(
            pointslist,
            Point(start.x + (unitx.x + unity.x) / 2, start.y + (unitx.y + unity.y) / 2),
        )
    else
        hilbert_helper(
            pointslist,
            start,
            Point(unity.x / 2, unity.y / 2),
            Point(unitx.x / 2, unitx.y / 2),
            depth - 1,
        )
        hilbert_helper(
            pointslist,
            Point(start.x + unitx.x / 2, start.y + unitx.y / 2),
            Point(unitx.x / 2, unitx.y / 2),
            Point(unity.x / 2, unity.y / 2),
            depth - 1,
        )
        hilbert_helper(
            pointslist,
            Point(start.x + unitx.x / 2 + unity.x / 2, start.y + unitx.y / 2 + unity.y / 2),
            Point(unitx.x / 2, unitx.y / 2),
            Point(unity.x / 2, unity.y / 2),
            depth - 1,
        )
        hilbert_helper(
            pointslist,
            Point(start.x + unitx.x / 2 + unity.x, start.y + unitx.y / 2 + unity.y),
            Point(-unity.x / 2, -unity.y / 2),
            Point(-unitx.x / 2, -unitx.y / 2),
            depth - 1,
        )
    end
    return pointslist
end

function hilbert(gif::Bool = true)
    num_frames = 1050
    video = Video(400, 400)
    Background(1:num_frames, ground)

    hilbertcurve = hilbert_helper(Point[], O - (128, 128), Point(256, 0), Point(0, 256), 5)
    n = length(hilbertcurve)
    colors = range(colorant"red", colorant"green", length = n ÷ 3)
    append!(colors, range(colorant"green", colorant"purple", length = n ÷ 3))
    append!(colors, range(colorant"purple", colorant"blue", length = n ÷ 3))

    fno = 2
    pointer = Object(JCircle(hilbertcurve[1], 2; color="white", action=:fill))
    for i = 2:n
        prev = hilbertcurve[i-1]
        next = hilbertcurve[i]
        diff = next - prev
        Object(fno:num_frames, JLine(prev, next; color = colors[i-1]))
        act!(pointer, Action(fno-1:fno, anim_translate(diff)))
        act!(pointer, Action(fno-1:fno, change(:color, colors[i-1])))
        fno += 1
    end

    render(video; pathname = if gif
        "hilbert.gif"
    else
        "hilbert.mp4"
    end, framerate = 30)
    return fno
end

hilbert()
hilbert(false)

#= Unused
function draw_line(
    p1 = O,
    p2 = O;
    color = "white",
    action = :stroke,
    edge = "solid",
    linewidth = 3,
)
    sethue(color)
    setdash(edge)
    setline(linewidth)
    line(p1, p2, action)
end

function draw_path!(path, pos, color)
    sethue(color)
    push!(path, pos)
    return draw_line.(path[2:end], path[1:(end-1)]; color = color)
end
=#