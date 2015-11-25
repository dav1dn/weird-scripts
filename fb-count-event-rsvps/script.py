import json

data = open('info.json')

def parse_data(data):
    data = json.load(data)
    inviters = {}
    statused = {}
    
    # guest_lists contains all 3 data sections: [0] is going, so on
    guest_lists = [data[x]["sections"] for x in ["going", "maybe", "invited", "declined"]]

    statused = {x:{} for x in (0, 1, 2, 3)}
    total_invitees = 0
    i = 0

    for guest_list in guest_lists:
        for section in guest_list:
            people = section[1]
            for person in people:
                inviter = person['subtitle']
                if inviter == None:
                    inviter = "Invited by Davegg"
                if inviter in inviters:
                    inviters[inviter] += 1
                else:
                    inviters[inviter] = 1
                if inviter in statused[i]:
                    statused[i][inviter] += 1
                else:
                    statused[i][inviter] = 1

        i += 1

    print("Name\t\t\tTotal \t Going \t Maybe \t Undec \t Declined")
    for inviter in sorted(inviters, key=inviters.get, reverse=1):
        name = str(inviter).replace("Invited by ", "")
        total = inviters[inviter]
        total_invitees += total
        going = statused[0].get(inviter, 0)
        maybe = statused[1].get(inviter, 0)
        undec = statused[2].get(inviter, 0)
        decli = statused[3].get(inviter, 0)
        print("{0:20}\t{1} \t {2} \t {3} \t {4} \t {5}".format(
            name, total, going, maybe, undec, decli))

    output = [total_invitees]
    output.extend([sum(statused[x].values()) for x in (0, 1, 2, 3)])
    print(" Total: {0}\n Going: {1}\n Maybe: {2}\n Undecided: {3}\n Declined: {4}".format(
        *output))
    assert output[0] == sum(output[1:5])

parse_data(data)
