# Meteor.methods
#     generate_rules_pdf: (signing_id)->
#         signing_doc = Docs.findOne signing_id
#         rule_doc = Docs.findOne
#             model:'document'
#             slug:'rules_regs'
#         rules = rule_doc.content
#         # console.log rules
#         user = Meteor.users.findOne username:signing_doc.resident
#         # console.log signing_doc
#         doc = new PDFDocument({size: 'A4', margin: 50})
#         doc.fontSize(12)
#         doc.font('Times-Bold').text("Gold Run Rules and Regulations Contract", {align: 'center'})
#         # console.log key,value
#         doc.font('Times-Roman').text(rules, {align: 'left', continued:false})
#         doc.font('Times-Bold').text(" Resident:#{signing_doc.resident}", {align: 'left'})
#         doc.image(signing_doc.signature, 200, 400, {width: 300})
#
#         # doc.moveDown();
#         doc.write("Gold_Run_Rules_Regs_Contract_#{doc.first_name}.pdf")
Meteor.methods
    generate_rules_pdf: (signing_id)->
        signing_doc = Docs.findOne signing_id
        rule_doc = Docs.findOne
            model:'document'
            slug:'rules_regs'
        rules = rule_doc.content
        console.log moment(@_timestamp).format("dddd, MMMM Do h:mm:ss a")
        human_timestamp = moment(@_timestamp).format("dddd, MMMM Do h:mm:ss a")

        # console.log rules
        user = Meteor.users.findOne username:signing_doc.resident
        # console.log signing_doc
        doc = new PDFDocument({size: 'A4', margin: 50})
        doc.fontSize(12)
        doc.font('Times-Bold').text("Gold Run Rules and Regulations Contract", {align: 'center'})
        # console.log key,value
        # doc.font('Times-Roman').text(rules, {align: 'left', continued:false})
        doc.font('Times-Roman').text("Dated July 2, 2014 GOLD RUN CONDOMINIUMS RULES AND REGULATIONS", {align:'left'})

        doc.font('Times-Roman').text("The purpose of these rules and regulations is to identify both specific and general standards of behavior that, in the judgment of the Board of Directors, are in the best interest of the majority of residents of Gold Run. Each of us, by choosing to live in a condominium community, has accepted the fact that we must be considerate of our neighbors. In tum, we expect that they will show the same consideration to us. By complying with these rules and regulations, each of us will be both giving and receiving the thoughtful respect that must be the cornerstone of safe and satisfying condominium living. A comprehensive listing of the use of condominiums may be found in article IX of the Gold Run Declarations.", {align:'left'})

        doc.font('Times-Roman').text("A. COVENANT ENFORCEMENT GENERALLY", {align:'left'})

        doc.font('Times-Roman').text("Reporting Violations. Complaints regarding alleged violations may be reported by an Owner or resident within the community, a group of Owners or residents, the Association's management company, if any, Board member(s) or committee member(s) by submission of a written or a verbal complaint.", {align:'left'})

        doc.font('Times-Roman').text("Investigation. Upon receipt of a complaint by the Association of any specific violation identified herein or any other violations of these Rules and Regulations of the Declaration, the Association shall investigate the complaint. If additional information is needed, the complaint may be returned to the owner submitting the complaint with a request for additional information.", {align:'left'})

        doc.font('Times-Roman').text("Initial Warning Letter. If a violation is found to exist, a warning letter shall be sent to the Violator (which includes both the Owner and Tenant if the Unit is rented) explaining the nature of the violation. The warning letter shall be posted on the door of the violating unit and sent via First Class Mail to unit owner at the contact address on file with the HOA. The letter must specify the alleged violation and the action required to abate the violation. Unless otherwise, specified herein, the Violator will have 20 days from the date of the letter to come into compliance.", {align:'left'})

        doc.font('Times-Roman').text("Continued Violation After Initial Warning Letter. If the alleged Violator does not come into compliance within 20 days of the first warning letter, this will be considered a second violation for which a fine may be imposed following notice and opportunity for a hearing. A second letter shall then be posted on the door of the violating unit and sent via First Class Mail to the unit owner, providing notice and an opportunity for a hearing, and explaining if a violation is found to exist, a fine may be imposed pursuant to this Policy. The letter shall further state that the alleged Violator is entitled to a hearing on the merits of the matter provided that such hearing is requested in writing within 10 days of the date on the second violation letter.", {align:'left'})

        doc.font('Times-Roman').text("Notice of Hearing. If a hearing is requested by the alleged Violator, the Board, committee or other person conducting such hearing as may be determined in the sole discretion of the Board, shall serve a written notice of the hearing to all parties involved at least 10 days prior to the hearing date. The notice shall contain the alleged violation, the time and place of the hearing, an invitation to attend the hearing and produce any statement, evidence, and witness on his/her, behalf, and the proposed sanction to be imposed.", {align:'left'})

        doc.font('Times-Roman').text("Failure to Timely Request Hearing. If the alleged Violator fails to request a hearing within 10 days of any letter, or fails to appear at any hearing, the Board may make a decision with respect to the alleged violation based on the Complaint, results of the investigation, and any other available information without the necessity of holding a formal hearing. If a violation is found to exist, the alleged Violator may be assessed a fine pursuant to these policies and procedures.", {align:'left'})

        doc.font('Times-Roman').text("Notification of Decision. The decision of the Board, committee or other person, shall be in writing and provided to the Violator and Complainant within 15 days of the hearing, or if no hearing is requested, within 10 days of the final decision.", {align:'left'})

        doc.font('Times-Roman').text("Fine Schedule. Unless a larger fine is identified below in these Rules and Regulations, the following fine schedule has been adopted for all recurring covenant violations:", {align:'left'})

        doc.font('Times-Roman').text("First Violation", {align:'left'})
        doc.font('Times-Roman').text("Second Violation of the Rules", {align:'left'})
        doc.font('Times-Roman').text("Third and subsequent violation of any rule", {align:'left'})
        doc.font('Times-Roman').text("Warning letter", {align:'left'})
        doc.font('Times-Roman').text("$25.00", {align:'left'})
        doc.font('Times-Roman').text("$50.00", {align:'left'})
        doc.font('Times-Roman').text("Third and subsequent covenant violations may be turned over to the Association's attorney to take appropriate legal action. Any Owner committing three or more violations in a 6 month period (whether such violations are of the same covenant or different covenants) may be immediately turned over to the Association's attorney for appropriate legal action.", {align:'left'})

        doc.font('Times-Roman').text("B. CONDOMINIUM UNITS, COMMON ELEMENTS AND COURTESY", {align:'left'})

        doc.font('Times-Roman').text("1. Owners are responsible for enforcing the occupancy requirements of their units as", {align:'left'})

        doc.font('Times-Roman').text("noted in the condominium declaration. Only two unrelated persons may reside in a 1 or 2-bedroom residence or 3 unrelated persons in a 3-bedroom residence. There are no 4-bedroom residences. Relationships/affiliations shall have the same definitions as depicted in the Boulder Zoning Code. Owners are subject to a fine of $100 for each violation. If the violation is not remedied within 30 days then owner shall be subject to additional fines of $50 per day. Residents in violation of these rules are subject to immediate eviction. All owners and tenants are required to provide a copy of any lease to the Gold Run Health Club within 10 days of the lease commencement date. Guests/visitors are not permitted to reside more than 14 consecutive days in a residence.", {align:'left'})

        doc.font('Times-Roman').text("2. Decks are limited common elements and they are subject to these rules and regulations. They must be neat in appearance. Only patio furniture is permitted on decks. Trash, tarps, interior furniture, appliances, kegs or large amounts of firewood may not be stored on the decks. Bikes may be kept on decks provided they are not visible above the line of the deck railing unless hung neatly from the ceiling above or wall. Decks shall not be used for hanging garments or other, articles for extended periods of time.", {align:'left'})

        doc.font('Times-Roman').text("3. Live foliage, kept in good condition may hang from decks during the summer months.", {align:'left'})

        doc.font('Times-Roman').text("4. Common elements, e.g., under stairs, hallways, parking spaces and in front of units, may not be used for storage (bicycles must be parked in accordance with section D-9 below). All hallways must be kept clear per City Fire Regulations. Any trash left in hallway will be hauled to trash and the Resident assessed a $25 fee after 1st notice and an opportunity for a hearing, and on each re-occurrence thereafter. Any object stored in a common area will removed and stored. A, storage fee of $50 will be charged to the Owner upon the Owner providing proof of ownership to the Association. If not claimed within 30 days items may be disposed.", {align:'left'})

        doc.font('Times-Roman').text("5. For rent or for sale signs are allowed to be placed in one [1] window only and are not to be more than five square feet per condominium unit. No other signs of any kind are permitted in Gold Run except for signs installed by the HOA and signs permitted by state statute.", {align:'left'})

        doc.font('Times-Roman').text("6. Interior structural modifications and any exterior modifications to units are not allowed without prior written consent of the architectural review committee.", {align:'left'})

        doc.font('Times-Roman').text("7. Solicitors are not allowed. They may be considered trespassing. If a solicitor comes to your door, you are encouraged to call Boulder City Police and make a complaint.", {align:'left'})

        doc.font('Times-Roman').text("8. Per environmental regulations, wood burning and barbecuing are not allowed during high pollution days. As a courtesy to your neighbors, you should avoid these activities on high wind days as well.", {align:'left'})

        doc.font('Times-Roman').text("9. Condominiums are for residential use only. Businesses or professionals that manufacture products, use hazardous chemicals, engage in dleliveries or pickups, or result in customer foot traffic may not be operated from a condominium unit.", {align:'left'})

        doc.font('Times-Roman').text("10. Only electric barbecues are permitted. Use of electric barbecues is authorized.  Inspection by the HOA of electric barbecue will be required and a sticker will be placed on barbecue.", {align:'left'})

        doc.font('Times-Roman').text("11. No charcoal or propane barbecues whatsoever. Highly Flammable Substances are prohibited. No highly Flammable Substances shall be used or stored in the units or on the Common Elements, including the Limited Common Element balconies, decks, patios, storage rooms, garages, and driveways. Examples of said provisions include: gasoline, kerosene, or propane which is stored on limited Common Element balconies, decks, patios, storage rooms, garages, driveways, and units. In addition planters must be ceramic or made of another nonflammable material. Wood or plastic planters are strictly prohibited.",{align:'left'})

        doc.font('Times-Roman').text("Barbecues Prohibited: Use or storage of charcoal or gas barbecues, hookah pipes, tiki torches, chimineas, fire pits, and other similar objects in the unit or on the Common Elements, including Limited Common Element balconies, patios and decks are strictly prohibited.", {align:'left'})

        doc.font('Times-Roman').text("Enforcement:", {align:'left'})

        doc.font('Times-Roman').text("First Violation:", {align:'left'})
        doc.font('Times-Roman').text("Second and Subsequent Violations:", {align:'left'})
        doc.font('Times-Roman').text("$1,000 (after notice and opportunity for a hearing)", {align:'left'})
        doc.font('Times-Roman').text("$2,000 (after notice and opportunity for a hearing)", {align:'left'})
        doc.font('Times-Roman').text("12. Leaks between Units. Any time a leak occurs or develops between units, the", {align:'left'})

        doc.font('Times-Roman').text("Board of Directors shall investigate the leak and the cause of the leak or water migration. The Board shall then, establish findings and make a determination as to whether or not the leak was a result of negligence.", {align:'left'})

        doc.font('Times-Roman').text("C. NUISANCES", {align:'left'})

        doc.font('Times-Roman').text("Generally, the following acts are hereby determined to be a nuisance and shall be prohibited within the Gold Run Community:", {align:'left'})

        doc.font('Times-Roman').text("1. No Smoking on Decks and Common Areas. NO SMOKING is allowed by anyone on any deck on the property, or in any common area including the grounds. This includes, but is not limited, to the smoking of cigarettes, cigars or marijuana.", {align:'left'})

        doc.font('Times-Roman').text("FINES for smoking on decks or in common areas shall be payable by owners for violations by owners, tenants, guests or invitees for a particular unit, and shall be $150 for the first offense per academic year (September 1 - August 30), $300 for the 2nd offense in the same academic year and for each offense thereafter. Cigarette butts found on the ground which can be positively traced to a particular unit shall also subject the owner of that unit to these same fines as shall, smoke odors in any area which can be positively traced to a particular unit.",{align:'left'})

        doc.font('Times-Roman').text("2. Noise. Residents shall exercise reasonable care to avoid disturbing, objectionable", {align:'left'})

        doc.font('Times-Roman').text("or loud noises or music at any time. If you notice excessive noise at any hour or are aware of damage to common property contact Colorado Security Company at 303-944-5183 or the Boulder Environmental Noise Department at 303-441-3239 or Boulder Police at 303-441-4444. Please call onsite management at 303-545-1787 to register the complaint for follow up.", {align:'left'})

        doc.font('Times-Roman').text("Once there has been an initial warning or complaint,* a fine of $200 plus a $35 administrative fee shall be levied against the unit Owner for any subsequent incident after notice and opportunity for a hearing.", {align:'left'})

        doc.font('Times-Roman').text("*For incidents occurring between the hours of 1O:OOpm and 7:00am no initial warning shall be given, and a fine of $200.00 plus a $35 administrative fee shall be levied against the unit.Owner after notice and opportunity for a hearing.", {align:'left'})

        doc.font('Times-Roman').text("The first subsequent incident within one year shall be subject to a $200 fine plus a $35 administrative fee; any further incidents within one year will be subject to a $500 fine plus a $35 administrative fee for each occurrence.", {align:'left'})

        doc.font('Times-Roman').text("Projectiles: No person residing within the Gold Run Condominium Community shall throw, launch, shoot or otherwise project any object, including pellets, BBs, fireworks, trash or water balloons from a Unit onto or at the Common Elements or at any individual within the Community. 3. Damage to Common Elements. No person residing within the Gold Run", {align:'left'})

        doc.font('Times-Roman').text("Community shall cause or permit to be caused any damage to the common elements either by their act or failure to act.", {align:'left'})

        doc.font('Times-Roman').text("4. Other Acts. Any other act which annoys or acts to harass another resident within", {align:'left'})

        doc.font('Times-Roman').text("Gold Run as may be determined in the reasonable discretion of the Board of Directors.", {align:'left'})

        doc.font('Times-Roman').text("5. Cost to Repair and Fines: In addition to the cost to repair any damage resulting", {align:'left'})

        doc.font('Times-Roman').text("from the above, the Association may, after notice and an opportunity for a hearing, levy fines in the following amounts.", {align:'left'})

        doc.font('Times-Roman').text("First Violation: Warning letter", {align:'left'})
        doc.font('Times-Roman').text("Second Violation: $100.00 (after notice and opportunity for a hearing)", {align:'left'})
        doc.font('Times-Roman').text("Third Violation: $200.00 (after notice and opportunity for a hearing)", {align:'left'})
        doc.font('Times-Roman').text("Fourth and Subsequent Violations: $500.00 (after notice and an opportunity for a hearing) Violations may be turned over to the Association' s attorney to take appropriate legal action at the sole discretion of the Board.", {align:'left'})
        doc.font('Times-Roman').text("D. VEHICLES AND PARKING", {align:'left'})
        doc.font('Times-Roman').text("1. Please use extreme caution while driving in the Gold Run community, and do not drive in a careless or reckless manner. Any reports of careless driving will be reported to the Police. Speed limit in garages is 5 mph.", {align:'left'})

        doc.font('Times-Roman').text("2. Parking is not permitted on lawns or in front of fire hydrants, fire lanes, garage", {align:'left'})

        doc.font('Times-Roman').text("doors, trash containers, blocking other vehicles, or where 'no parking' notices are posted or in residents assigned parking space. Call Boulder Valley Towing at 303-444-4868 to have a vehicle towed at the vehicle owner's expense in emergency situations. Owners of a vehicle parked in violation of this policy may not be given notice.", {align:'left'})

        doc.font('Times-Roman').text("3. Vehicles shall be parked within designated parking spaces within the community. Each Owner and Tenant shall use their assigned space for the primary parking. Any violation of this shall be subject to enforcement pursuant to Section A above.", {align:'left'})

        doc.font('Times-Roman').text("4. The owner of a vehicle shall be responsible for any damage done by the vehicle to Gold Run property including but not limited to the garage door and frame, garage door opener, pipes, structural elements, and garage floor. Persons responsible, including the owner of the unit, may be assessed any costs attributable to required repairs.", {align:'left'})

        doc.font('Times-Roman').text("5. The City of Boulder limits parking on city streets to a period of 48 hours.", {align:'left'})

        doc.font('Times-Roman').text("Vehicles in violation may be reported to the City Police. Vehicles parked in Gold Run Visitor parking are limited to 48 hours. Vehicles cannot be stored on Gold Run property. Vehicles that are not used on a regular basis, stored on Gold Run property, or parked in excess of 48 hours in Visitor parking will be tagged and then towed within 48 hours at Resident's expense.", {align:'left'})

        doc.font('Times-Roman').text("6. Except for first responder vehicles as defined by Colorado law, Commercial vehicles and vehicles larger than -%-ton pickup trucks are not allowed on Gold Run property, except for the express purpose of moving household goods, trash or maintenance. No parking of oversized vehicles, stored vehicles, trailers, boats or campers of any kind is allowed on Gold Run property.", {align:'left'})

        doc.font('Times-Roman').text("7. Vehicle maintenance is not permitted on the Gold Run common elements, including limited common elements. Vehicle maintenance using jacks, jack stands or blocks is not permitted except for the purpose of changing flat tires, any damage to the asphalt or common area will be assessed to the condominium resident.", {align:'left'})

        doc.font('Times-Roman').text("8. Because of environmental regulations and continuing damage to the association's common property, you may not change any oil or other fluids in your vehicles on Gold Run property. No disposal of oil, motor vehicle fluids, or other hazardous waste in trash containers or on Gold Run property is permitted.", {align:'left'})

        doc.font('Times-Roman').text("9. Bicycles may be stored only in designated bicycle racks, in front of assigned parking spaces, or in residences (not attached to front stairs or common areas which includes hallways, entries, decks, poles, etc.). Bikes that are being stored in other areas will be impounded, and the lock cut at owner's expense without notice. Owners may retrieve bikes from storage pursuant to Section B.4 above. The HOA is not responsible for the bike while in storage. Bikes must be claimed, immediately. Motorcycles may only be parked in front of assigned parking spaces or in designated motorcycle parking areas.",{align:'left'})

        doc.font('Times-Roman').text("10. Skate boarding is not allowed on common elements.", {align:'left'})

        doc.font('Times-Roman').text("E. PETS", {align:'left'})
        doc.font('Times-Roman').text("1. Dogs are not allowed at any time anywhere at Gold Run. The only exception is for residents or visitors who require a seeing-eye dog or similar canine assistance to address a disability. Resident shall be fined for each violation relating to dogs at Gold Run after the 1st notice, pursuant to Section A above.", {align:'left'})

        doc.font('Times-Roman').text("Renters are not allowed to have pets of any kind except for the exception stated above.", {align:'left'})

        doc.font('Times-Roman').text("2. Other small animals generally recognizable as pets are allowed only in units occupied by owners, and then only with a specific written agreement between the unit owner and the Condominium Association.", {align:'left'})

        doc.font('Times-Roman').text("Cats must remain inside the units and not be allowed in hallways or common areas.", {align:'left'})

        doc.font('Times-Roman').text("3. An owner (whether they are resident or not) shall be fined $100 for each violation after the 1st notice of the requirements related to animals. Repeated violators may be subject to a fine of $200 for the 3rd notice and $500 for each subsequent notice.", {align:'left'})

        doc.font('Times-Roman').text("F. HEALTH CLUB", {align:'left'})

        doc.font('Times-Roman').text("1. Each Gold Run condominium unit may have as many health club memberships as permanent occupants provided that this number does not exceed the maximum occupancy rules contained herein. Proof of residency and a copy of any lease or rental agreement will be required by the Gold Run Health Club staff, which shall have the authority to permit or deny use of the facilities.", {align:'left'})

        doc.font('Times-Roman').text("Members without membership cards will not be allowed use of the facilities. Non-occupant homeowners will retain their membership privileges.", {align:'left'})

        doc.font('Times-Roman').text("2. Each member will be issued a membership card. Entrance will only be allowed with a membership card. Guests may use the facilities only when accompanied by a member ( 4 guest visits are allowed each month).", {align:'left'})

        doc.font('Times-Roman').text("3. Each member may reserve only one hour of tennis or racquetball court time per day (additional time may be scheduled at end of play time, if no other members are waiting). All members playing together are considered to have made their comt reservation for the day. Reservations will be accepted 24 hours in advance.", {align:'left'})

        doc.font('Times-Roman').text("4. Appropriate shoes and upper torso garments, as well as tights, shorts or sweats must be worn in all workout areas except pool, hot tub and deck areas where only a swimsuit may be worn.", {align:'left'})

        doc.font('Times-Roman').text("5. Lockers are available to members but locks must be removed after every use and before health club closes for the night. All belongings not needed for activities should be kept in the lockers (not in hallways, decks, pool areas, or exercise room.", {align:'left'})

        doc.font('Times-Roman').text("6. All children 14 years or younger must be supervised by an adult at all times.", {align:'left'})

        doc.font('Times-Roman').text("7. No children 14 years or under allowed in the weight room.", {align:'left'})

        doc.font('Times-Roman').text("8. Food, glass containers or canned beverages are not allowed into exercise areas, pool, spa or locker rooms. Alcohol, tobacco products, and controlled substances are not permitted on the health club premises.", {align:'left'})

        doc.font('Times-Roman').text("9. Members and guests are not allowed in the health club, volleyball court or tennis court while under the influence of drugs or alcohol.", {align:'left'})

        doc.font('Times-Roman').text("10. There is no lifeguard on duty. Therefore, swimming is at the sole risk of the individual. Running on the pool deck and diving or jumping into the pool is not allowed.", {align:'left'})

        doc.font('Times-Roman').text("11. Bathing suits must be worn at all times in the deck areas, pool areas, and hot tubs, as required by Colorado law. Members and guests must shower before entering spa or pool.", {align:'left'})

        doc.font('Times-Roman').text("12. For health and safety reasons, the maximum suggested time limit in steam rooms, saunas and hot tub is 30 minutes.", {align:'left'})

        doc.font('Times-Roman').text("13. Telephone calls on the courtesy telephone are limited to three minutes. No more than two calls per visit are allowed. The lost and found box will be emptied at the end of each month. Gold Run Health Club is not responsible for lost or stolen property.", {align:'left'})

        doc.font('Times-Roman').text("14. Equipment is offered for loan with a photo ID and health club membership cards.", {align:'left'})

        doc.font('Times-Roman').text("15. Gold Run reserves the right to revoke health club membership for Renters or Owners not in good standing with the association, or for violation of rules and Regulations, or for behavior that is discourteous or threatening in any way to members of staff, or abuse of the facilities.", {align:'left'})

        doc.font('Times-Roman').text("Gold Run On-site manager: Rick Hamp 303.545.1787 ", {align:'left'})
        doc.font('Times-Roman').text("E-mail address: goldruncondos@gmail.com", {align:'left'})
        doc.font('Times-Roman').text("Website: http://www.goldruncondos.com/", {align:'left'})
        doc.font('Times-Roman').text("Associationonline.com User Name and Password: GRC88", {align:'left'})


        # doc.font('Times-Bold').text(" Username:#{user.username}", {align: 'left'})
        doc.font('Times-Bold').text(" Name: #{user.first_name} #{user.last_name}", {align: 'left'})
        doc.font('Times-Bold').text(" When: #{human_timestamp}", {align: 'left'})
        # doc.font('Times-Bold').text(" Last Name:#{user.last_name}", {align: 'left'})
        doc.image(signing_doc.signature, 200, 600, {width: 300})

        # doc.moveDown();
        doc.write("Gold_Run_Rules_Regs_Contract_#{user.username}.pdf")
