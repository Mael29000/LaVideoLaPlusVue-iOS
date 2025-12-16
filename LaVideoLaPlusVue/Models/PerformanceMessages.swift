//
//  PerformanceMessages.swift
//  LaVideoLaPlusVue
//
//  Created by Assistant on 27/10/2025.
//

import Foundation

/**
 * Gestionnaire de messages humoristiques pour les performances normales (sans nouveau record).
 * Les messages sont adaptés au score avec différents niveaux d'humour et de sarcasme.
 */
struct PerformanceMessages {
    
    /**
     * Retourne un message humoristique adapté au score pour une performance normale.
     * - Parameter score: Le score de la partie
     * - Returns: Un message humoristique
     */
    static func getMessage(for score: Int) -> String {
        switch score {
        case 0:
            return messages0.randomElement() ?? "Bien joué !"
        case 1:
            return messages1.randomElement() ?? "Bien joué !"
        case 2:
            return messages2.randomElement() ?? "Bien joué !"
        case 3:
            return messages3.randomElement() ?? "Bien joué !"
        case 4...5:
            return messages4to5.randomElement() ?? "Bien joué !"
        case 6...9:
            return messages6to8.randomElement() ?? "Bien joué !"
        case 10...12:
            return messages9to12.randomElement() ?? "Bien joué !"
        case 13...15:
            return messages13to15.randomElement() ?? "Bien joué !"
        case 16...18:
            return messages16to18.randomElement() ?? "Bien joué !"
        case 19...20:
            return messages19to20.randomElement() ?? "Bien joué !"
        case 21...25:
            return messages21to25.randomElement() ?? "Bien joué !"
        case 26...30:
            return messages26to30.randomElement() ?? "Bien joué !"
        default:
            return messages30plus.randomElement() ?? "Bien joué !"
        }
    }
    
    // MARK: - Messages par niveau de score
    
    private static let messages0 = [
        "0 pointé ! T'as fermé les yeux ou quoi ?",
        "Alors là... même en cliquant au hasard on fait mieux !",
        "Impressionnant ! Faut le faire pour avoir 0 !",
        "Concentre-toi Kevin !",
        "0 vidéo... Tu connais YouTube au moins ?",
        "T'as confondu avec Netflix ou quoi ?",
        "C'est pas Tinder ici, faut pas selectionner celui que tu touve le plus beau !",
        "0 points... c'est une habitude ?",
        "T'as fait exprès ? C'est pour la science ?",
        "T'es sûr d'avoir internet ?",
        "T'as YouTube Kids peut-être ? C'est pas la même chose !",
        "0 point ! T'as battu... personne en fait.",
        "C'était un échauffement j'espère ?",
        "T'as cliqué avec tes pieds ?",
        "Même en dormant on peut faire 1 point !",
        "0 point ! Même pas par accident... c'est fou !"
    ]
    
    private static let messages1 = [
        "1 point ! C'est un début... très timide !",
        "Une vidéo ! Au moins t'as pas fait 0 !",
        "1 point... T'as cliqué au hasard avoue !",
        "Bon, c'est pas brillant mais c'est pas zéro !",
        "Bravo ! Tu sais cliquer ! C'est déjà ça !",
        "C'est mieux que rien... mais c'est pas fou !",
        "Au moins t'as trouvé le bouton pour jouer !",
        "1 vidéo reconnue ! T'as dû la voir passer par hasard !",
        "C'est pas terrible mais c'est un début !",
        "C'est pas la gloire mais c'est pas la honte !",
    ]
    
    private static let messages2 = [
        "2 points ! Tu doubles ta performance habituelle ?",
        "Pas mal ! Enfin... si on est très gentil.",
        "2 points ! Tu progresses doucement mais sûrement !",
        "C'est moins bien que la dernière fois... j'espère ?",
        "Tu montes en puissance... très lentement !",
        "2 points ! À ce rythme, dans 5 ans t'es bon !",
        "Pas mal ! Tu quittes la catégorie 'désastre' !",
        "C'est mieux que 1... mais c'est pas 3 !",
        "C'est un progrès... minuscule mais réel !",
        "2 vidéos ! T'as reconnu tes deux préférées ?"
    ]
    
    private static let messages3 = [
        "3 points ! Ça commence à ressembler à quelque chose !",
        "Tu t'améliores ! Lentement mais sûrement !",
        "C'est pas mal pour quelqu'un qui regarde peu !",
        "Tu commences à comprendre le principe (t'emballe pas trop) !",
        "C'est mieux que la moyenne... de tes scores !",
        "C'est pas si faible ! Tu progresses ! (enfin un peu)",
    ]
    
    private static let messages4to5 = [
        "Tu commences à être fort... pour les debutants !",
        "Bravo ! Tu sors de la catégorie 'désastre total' !",
        "Tu reconnais plus de vidéos que la moyenne... c'est déjà ça !",
        "C'est correct ! Tu deviens un habitué !",
        "Tu t'améliores ! Continue comme ça !",
        "Bravo ! Tu connais YouTube mieux que la moyenne !",
        "C'est pas mal ! On vois que tu as les yeux ouverts !"
    ]
    
    private static let messages6to8 = [
        "Ok ça devient sérieux !",
        "Tu passes du temps sur YouTube, ça se voit (n'oublie pas de prendre l'air) !",
        "C'est fort ! Tu connais bien YouTube !",
        "C'est plus du hasard à ce niveau (enfin) !",
        "Félicitations ! Pour atteindre ce score faut avoir visionne les trefonds des tendances !",
    ]
    
    private static let messages9to12 = [
        "Double chiffres ! Bienvenue dans l'élite locale !",
        "Enfin un vrai score !",
        "Tu as su eviter les pieges ! Bravo !",
        "Et oui, on a mis beaucoup de videos de macron (il est partout) !",
        "Intraitable !"
    ]
    
    private static let messages13to15 = [
        "Ok c'est louche...",
        "On devrait vérifier ton historique... c'est suspect !",
        "Waow ! T'es un pro !",
        "T'as dû binge-watcher YouTube non-stop !",
        "Plusieurs prières ont été réalisées pour  obtenir ce score!",
    ]
    
    private static let messages16to18 = [
        "Là on frôle la triche quand même !",
        "On veut la VAR ! C'est pas possible !",
        "Tu mates en x2 pour optimiser ?",
        "Avoue, t'as YouTube ouvert à côté !",
        "Incroyable ! T'es abonné à combien de chaînes ?!",
        "C'est plus une passion, c'est une obsession !"
    ]
    
    private static let messages19to20 = [
        "Tu ES YouTube à ce stade !",
        "Montre tes logs de navigation !",
        "Tu dors dans les data centers YouTube ?",
        "T'es payé pour regarder autant de vidéos ?"
    ]
    
    private static let messages21to25 = [
        "Champion ! Partage ton secret !",
        "Tu rêves en miniatures la nuit !",
        "T'as un doctorat en YouTube Culture ?"
    ]
    
    private static let messages26to30 = [
        "L'Élu de la prophétie c'est toi !",
        "Tu ES les tendances !",
        "On est sur du temps d'écran de compétition là !",
        "Doux jesus !"
    ]
    
    private static let messages30plus = [
        "C'est de la sorcellerie à ce niveau !",
        "Même nous (les créateurs) on fait pas ça !",
        "T'as un pacte avec l'algorithme ?",
        "Faut qu'on parle de tes habitudes...",
        "On envoie un détective vérifier !",
        "C'est plus humain ! Robot confirmé !",
        "Stop ! C'est dangereux pour ta santé !",
        "On va devoir te bannir pour ton bien !",
        "Direction : centre de désintox YouTube !"
    ]
}
	
